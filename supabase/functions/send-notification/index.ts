import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "https://esm.sh/jose@4";
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1) Gelen body'den userId al
    const { userId } = await req.json();
    if (!userId) throw new Error("userId eksik!");

    // 2) Supabase admin istemcisi
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // 3) Kullanicinin fcm_token’ini çek
    const { data: user, error } = await supabaseAdmin
      .from("users")
      .select("fcm_token")
      .eq("id", userId)
      .single();
    if (error) throw error;
    if (!user?.fcm_token) throw new Error("Cihaz token bulunamadı!");

    // 4) Hizmet hesabı bilgilerini secret’lardan al
    const clientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
    let privateKey   = Deno.env.get("FIREBASE_PRIVATE_KEY")!;
    const projectId  = Deno.env.get("FIREBASE_PROJECT_ID")!;
    if (!clientEmail || !privateKey || !projectId) {
      throw new Error("Eksik Firebase credential!");
    }
    // JSON’da \n olarak gelen satır sonlarını gerçek newline’a çevir
    privateKey = privateKey.replace(/\\n/g, "\n");

    // 5) JWT oluştur
    const now = Math.floor(Date.now() / 1000);
    const alg = "RS256";
    const jwt = await new SignJWT({
      scope: "https://www.googleapis.com/auth/firebase.messaging",
    })
      .setProtectedHeader({ alg, typ: "JWT" })
      .setIssuedAt(now)
      .setExpirationTime(now + 3600) // 1 saat
      .setIssuer(clientEmail)
      .setAudience("https://oauth2.googleapis.com/token")
      .sign(await importPKCS8(privateKey, alg));

    // 6) OAuth token al
    const tokenRes = await fetch(
      "https://oauth2.googleapis.com/token",
      {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
          grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
          assertion: jwt,
        }),
      }
    );
    const tok = await tokenRes.json();
    if (!tok.access_token) throw new Error("OAuth token alınamadı!");

    // 7) FCM V1 endpoint’ine bildirimi gönder
    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${tok.access_token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: user.fcm_token,
            notification: {
              title: "Rezervasyon Güncellemesi",
              body:  "Durumunuz güncellendi!",
            },
          },
        }),
      }
    );
    if (!fcmRes.ok) {
      const err = await fcmRes.text();
      throw new Error("FCM V1 hatası: " + err);
    }

    // 8) Başarıyla dön
    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (e: any) {
    console.error(e);
    return new Response(JSON.stringify({ error: e.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
