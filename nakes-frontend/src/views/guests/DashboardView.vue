<template>
  <div class="landing-page">

    <!-- NAVBAR -->
    <NavbarView />

    <!-- HERO SECTION -->
    <section class="hero">
      <div class="orb orb1"></div>
      <div class="orb orb2"></div>
      <div class="orb orb3"></div>

      <div class="hero-left">
        <h1>
          Jangan Pernah<br>
          Lupa Minum Obat<br>
          Bersama <span class="brand">Pil Time</span>
        </h1>
        <p class="hero-desc">
         Pil Time hadir sebagai solusi untuk membantu pengguna mengatur jadwal minum obat dengan lebih mudah, teratur, dan tepat waktu. Aplikasi ini menyediakan fitur pengingat konsumsi obat, pemantauan kepatuhan harian, serta pencatatan riwayat 
         penggunaan obat untuk membantu pengguna menjaga rutinitas kesehatan secara konsisten. 
         Dengan tampilan yang sederhana dan mudah digunakan, Pil Time membantu pengguna agar tidak lupa minum obat dan tetap disiplin dalam menjalani pengobatan setiap hari.
        </p>
        <div class="hero-btns">
          <router-link to="/install" class="btn-primary">📥 Download APK</router-link>
          <router-link to="/tentang" class="btn-secondary">Tentang Pil Time →</router-link>
        </div>
      </div>

      <!-- PHONE MOCKUP -->
      <div class="hero-right">
        <div class="phone-wrap">
          <div class="phone-glow"></div>

          <div class="pill-float pf1"><span class="dot"></span> Obat diminum ✓</div>
          <div class="pill-float pf2"><span class="dot"></span> Reminder aktif</div>
          <div class="pill-float pf3"><span class="dot"></span> 78% tercapai</div>

          <div class="phone">
            <div class="screen">
              <div class="screen-header">
                <div>
                  <div class="screen-greeting">Selamat Siang, 👋</div>
                  <div class="screen-name">Hizkia Cristian</div>
                </div>
                <div class="screen-bell">🔔</div>
              </div>

              <div class="comply-card">
                <div class="comply-label">Kepatuhan Hari Ini</div>
                <div class="comply-val">1 dari 2 Selesai</div>
                <div class="comply-bar"><div class="comply-fill"></div></div>
                <div class="comply-sub">Ayo selesaikan sesi malam tepat waktu!</div>
              </div>

              <div class="menu-label">Menu Utama</div>
              <div class="menu-grid">
                <div class="menu-item">
                  <div class="menu-icon">⏰</div>
                  <div class="menu-name">Reminder</div>
                  <div class="menu-sub green">Kelola Pengingat</div>
                </div>
                <div class="menu-item">
                  <div class="menu-icon">💊</div>
                  <div class="menu-name">Info Obat</div>
                  <div class="menu-sub amber">Detail & Panduan</div>
                </div>
                <div class="menu-item">
                  <div class="menu-icon">📊</div>
                  <div class="menu-name">Riwayat</div>
                  <div class="menu-sub blue">Kepatuhan Minum</div>
                </div>
                <div class="menu-item">
                  <div class="menu-icon">🏃</div>
                  <div class="menu-name">Rutinitas</div>
                  <div class="menu-sub purple">Jadwal Aktivitas</div>
                </div>
              </div>

              <div class="bottom-nav">
                <div class="bnav-item active">
                  <span class="bnav-icon">🏠</span>
                  <span>Beranda</span>
                </div>
                <div class="bnav-item">
                  <div class="bnav-plus">+</div>
                </div>
                <div class="bnav-item">
                  <span class="bnav-icon">👤</span>
                  <span>Profil</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- FEATURES -->
    <section class="features">
      <div class="section-head">
        <div class="section-tag">✨ Fitur Unggulan</div>
        <h2 class="section-title">Kenapa Harus Pil Time?</h2>
      </div>
      <div class="feat-grid">
        <div class="feat-card">
          <div class="feat-icon g">⏰</div>
          <div class="feat-title">Reminder & Alarm</div>
          <p class="feat-desc">Atur pengingat minum obat otomatis dengan alarm cerdas agar tidak pernah terlewat satu pun dosis.</p>
        </div>
        <div class="feat-card">
          <div class="feat-icon o">💊</div>
          <div class="feat-title">Info Obat Lengkap</div>
          <p class="feat-desc">Akses detail ribuan obat — dosis, efek samping, dan panduan penggunaan yang tepat dan terpercaya.</p>
        </div>
        <div class="feat-card">
          <div class="feat-icon b">📊</div>
          <div class="feat-title">Riwayat Kepatuhan</div>
          <p class="feat-desc">Pantau histori minum obat harian dan mingguan dengan grafik yang mudah dipahami.</p>
        </div>
        <div class="feat-card">
          <div class="feat-icon t">🏃</div>
          <div class="feat-title">Rutinitas Sehat</div>
          <p class="feat-desc">Bangun jadwal aktivitas sehat yang konsisten dengan dukungan pengingat dan panduan rutin harian.</p>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <div class="cta-section">
      <div class="cta-inner">
        <div class="cta-eyebrow">
          <span class="cta-eyebrow-dot"></span>
          Mulai gratis, tanpa kartu kredit
        </div>
        <h2 class="cta-title">
          Kesehatan Kamu<br>
          Terlalu Berharga<br>
          untuk <span class="highlight">Dilupakan</span>
        </h2>
        <p class="cta-desc">
          Ribuan orang sudah menjaga kepatuhan minum obat mereka bersama Pil Time.
          Saatnya kamu bergabung dan mulai hidup lebih sehat hari ini.
        </p>
        <div class="cta-btns">
          <router-link to="/install" class="cta-btn-main">📥 Download Sekarang</router-link>
          <router-link to="/panduan" class="cta-btn-ghost">Lihat Panduan →</router-link>
        </div>
        <div class="trust-row">
          <div class="trust-item">✅ Gratis selamanya</div>
          <div class="trust-divider"></div>
          <div class="trust-item">🔒 Data aman & privat</div>
          <div class="trust-divider"></div>
          <div class="trust-item">📱 Android & iOS</div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import NavbarView from './NavbarView.vue'

export default {
  name: 'LandingView',
  components: { NavbarView }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');

* { margin: 0; padding: 0; box-sizing: border-box; }

.landing-page {
  font-family: 'Plus Jakarta Sans', sans-serif;
  background: #f0faf5;
  color: #0f172a;
}

/* ─── HERO ─── */
.hero {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;
  padding: 100px 6% 80px;
  gap: 60px;
  position: relative;
  overflow: hidden;
}

/* orbs */
.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  pointer-events: none;
  animation: float 8s ease-in-out infinite;
}
.orb1 { width: 500px; height: 500px; background: rgba(22,163,74,0.12); top: -100px; left: -100px; animation-delay: 0s; }
.orb2 { width: 400px; height: 400px; background: rgba(37,99,235,0.10); bottom: -80px; right: -80px; animation-delay: 3s; }
.orb3 { width: 300px; height: 300px; background: rgba(13,148,136,0.08); top: 40%; left: 40%; animation-delay: 1.5s; }

@keyframes float {
  0%, 100% { transform: translateY(0) scale(1); }
  50%       { transform: translateY(-20px) scale(1.05); }
}

/* hero left */
.hero-left { position: relative; z-index: 2; }

h1 {
  font-size: 56px;
  font-weight: 800;
  line-height: 1.15;
  color: #0f172a;
  margin-bottom: 22px;
  letter-spacing: -1px;
  animation: fadeUp 0.6s 0.2s ease both;
}
h1 .brand {
  background: linear-gradient(135deg, #16a34a, #2563eb);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-desc {
  font-size: 17px;
  line-height: 1.85;
  color: #475569;
  margin-bottom: 36px;
  max-width: 480px;
  animation: fadeUp 0.6s 0.3s ease both;
}

.hero-btns {
  display: flex;
  gap: 14px;
  flex-wrap: wrap;
  animation: fadeUp 0.6s 0.4s ease both;
}

.btn-primary {
  background: linear-gradient(135deg, #16a34a, #22c55e);
  color: white;
  text-decoration: none;
  padding: 15px 30px;
  border-radius: 50px;
  font-size: 15px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: .3s;
  box-shadow: 0 8px 24px rgba(22,163,74,0.35);
}
.btn-primary:hover { transform: translateY(-3px); box-shadow: 0 14px 32px rgba(22,163,74,0.45); }

.btn-secondary {
  background: white;
  color: #0f172a;
  text-decoration: none;
  padding: 15px 30px;
  border-radius: 50px;
  font-size: 15px;
  font-weight: 600;
  border: 1.5px solid rgba(0,0,0,0.1);
  transition: .3s;
}
.btn-secondary:hover { border-color: #16a34a; color: #16a34a; transform: translateY(-3px); }

/* hero right — phone */
.hero-right {
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  z-index: 2;
  animation: fadeLeft 0.8s 0.3s ease both;
}

.phone-wrap {
  position: relative;
  animation: phoneBob 6s ease-in-out infinite;
}
@keyframes phoneBob {
  0%, 100% { transform: translateY(0) rotate(-2deg); }
  50%       { transform: translateY(-14px) rotate(-2deg); }
}

.phone-glow {
  position: absolute;
  width: 300px; height: 300px;
  background: radial-gradient(circle, rgba(22,163,74,0.2) 0%, transparent 70%);
  top: 50%; left: 50%;
  transform: translate(-50%, -50%);
  border-radius: 50%;
  pointer-events: none;
}

/* floating badges */
.pill-float {
  position: absolute;
  background: white;
  border-radius: 16px;
  padding: 10px 14px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.1);
  font-size: 12px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  animation: floatPill 5s ease-in-out infinite;
}
.pill-float .dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.pf1 { top: 10%; right: -20px; animation-delay: 0s;   color: #16a34a; } .pf1 .dot { background: #16a34a; }
.pf2 { bottom: 22%; left: -30px; animation-delay: 1.5s; color: #2563eb; } .pf2 .dot { background: #2563eb; }
.pf3 { top: 50%; right: -40px; animation-delay: 3s;   color: #0d9488; } .pf3 .dot { background: #0d9488; }
@keyframes floatPill {
  0%, 100% { transform: translateY(0); }
  50%       { transform: translateY(-8px); }
}

/* phone frame */
.phone {
  width: 270px; height: 560px;
  background: #0f172a;
  border-radius: 44px;
  padding: 12px;
  box-shadow: 0 40px 80px rgba(0,0,0,0.2), 0 0 0 1px rgba(255,255,255,0.06);
  position: relative;
}
.phone::before {
  content: '';
  position: absolute;
  top: 18px; left: 50%;
  transform: translateX(-50%);
  width: 90px; height: 28px;
  background: #0f172a;
  border-radius: 20px;
  z-index: 10;
}

.screen {
  width: 100%; height: 100%;
  border-radius: 34px;
  background: linear-gradient(160deg, #f0faf5 0%, #e0f2fe 100%);
  overflow: hidden;
  position: relative;
}

.screen-header {
  padding: 42px 18px 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.screen-greeting { font-size: 11px; color: #64748b; }
.screen-name     { font-size: 14px; font-weight: 700; color: #0f172a; }
.screen-bell     { width: 34px; height: 34px; border-radius: 50%; background: rgba(22,163,74,0.15); display: flex; align-items: center; justify-content: center; font-size: 16px; }

.comply-card {
  margin: 0 14px 14px;
  background: linear-gradient(135deg, #16a34a, #22c55e);
  border-radius: 20px;
  padding: 16px;
  color: white;
  position: relative;
  overflow: hidden;
}
.comply-card::after { content: ''; position: absolute; width: 100px; height: 100px; background: rgba(255,255,255,0.08); border-radius: 50%; top: -30px; right: -20px; }
.comply-label { font-size: 10px; font-weight: 600; opacity: .8; text-transform: uppercase; letter-spacing: .5px; }
.comply-val   { font-size: 22px; font-weight: 800; margin: 4px 0; }
.comply-bar   { height: 6px; background: rgba(255,255,255,0.25); border-radius: 10px; margin: 8px 0 6px; }
.comply-fill  { height: 100%; width: 78%; background: white; border-radius: 10px; animation: grow 1.5s 0.8s ease both; transform-origin: left; }
@keyframes grow { from { width: 0; } to { width: 78%; } }
.comply-sub { font-size: 10px; opacity: .8; }

.menu-label { padding: 10px 18px 6px; font-size: 12px; font-weight: 700; color: #0f172a; }
.menu-grid  { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; padding: 0 14px; }
.menu-item  { background: white; border-radius: 16px; padding: 14px 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
.menu-icon  { font-size: 22px; margin-bottom: 8px; }
.menu-name  { font-size: 11px; font-weight: 700; color: #0f172a; }
.menu-sub   { font-size: 10px; color: #64748b; }
.menu-sub.green  { color: #16a34a; }
.menu-sub.amber  { color: #d97706; }
.menu-sub.blue   { color: #2563eb; }
.menu-sub.purple { color: #7c3aed; }

.bottom-nav {
  position: absolute; bottom: 0; left: 0; right: 0;
  background: white;
  border-top: 1px solid rgba(0,0,0,0.06);
  display: flex;
  justify-content: space-around;
  align-items: center;
  padding: 10px 0 14px;
  border-radius: 0 0 34px 34px;
}
.bnav-item        { display: flex; flex-direction: column; align-items: center; gap: 3px; font-size: 10px; font-weight: 600; color: #94a3b8; }
.bnav-item.active { color: #16a34a; }
.bnav-icon        { font-size: 20px; }
.bnav-plus        { width: 44px; height: 44px; border-radius: 50%; background: linear-gradient(135deg, #16a34a, #22c55e); display: flex; align-items: center; justify-content: center; font-size: 22px; color: white; box-shadow: 0 4px 14px rgba(22,163,74,0.4); margin-top: -12px; }

/* ─── FEATURES ─── */
.features    { padding: 100px 6%; background: white; }
.section-head { text-align: center; margin-bottom: 60px; }
.section-tag  { display: inline-block; background: rgba(22,163,74,0.1); color: #16a34a; padding: 6px 16px; border-radius: 50px; font-size: 13px; font-weight: 600; margin-bottom: 14px; }
.section-title { font-size: 40px; font-weight: 800; color: #0f172a; letter-spacing: -0.5px; }

.feat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 24px; }
.feat-card {
  background: #f8fafc;
  border-radius: 24px;
  padding: 32px;
  transition: .3s;
  border: 1.5px solid transparent;
}
.feat-card:hover { background: white; border-color: rgba(22,163,74,0.2); transform: translateY(-6px); box-shadow: 0 16px 40px rgba(22,163,74,0.1); }

.feat-icon       { width: 52px; height: 52px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 26px; margin-bottom: 18px; }
.feat-icon.g     { background: rgba(22,163,74,0.12); }
.feat-icon.b     { background: rgba(37,99,235,0.10); }
.feat-icon.t     { background: rgba(13,148,136,0.10); }
.feat-icon.o     { background: rgba(234,179,8,0.12); }
.feat-title      { font-size: 17px; font-weight: 700; color: #0f172a; margin-bottom: 10px; }
.feat-desc       { font-size: 14px; line-height: 1.75; color: #475569; }

/* ─── CTA ─── */
.cta-section {
  margin: 0 4% 80px;
  background: linear-gradient(135deg, #0f172a 0%, #14532d 50%, #1e3a8a 100%);
  border-radius: 32px;
  padding: 80px 6%;
  text-align: center;
  position: relative;
  overflow: hidden;
}
.cta-section::before {
  content: ''; position: absolute;
  width: 500px; height: 500px;
  border: 1px solid rgba(255,255,255,0.06);
  border-radius: 50%; top: -200px; left: -150px;
}
.cta-section::after {
  content: ''; position: absolute;
  width: 400px; height: 400px;
  border: 1px solid rgba(255,255,255,0.05);
  border-radius: 50%; bottom: -180px; right: -100px;
}
.cta-inner { position: relative; z-index: 2; }

.cta-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.12);
  color: rgba(255,255,255,0.8);
  padding: 8px 18px;
  border-radius: 50px;
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 28px;
}
.cta-eyebrow-dot { width: 7px; height: 7px; background: #22c55e; border-radius: 50%; animation: pulse 2s infinite; }
@keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: .5; transform: scale(.8); } }

.cta-title {
  font-size: 48px;
  font-weight: 800;
  color: white;
  margin-bottom: 16px;
  letter-spacing: -1px;
  line-height: 1.1;
}
.cta-title .highlight {
  background: linear-gradient(135deg, #22c55e, #60a5fa);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.cta-desc {
  font-size: 17px;
  color: rgba(255,255,255,0.6);
  max-width: 500px;
  margin: 0 auto 44px;
  line-height: 1.85;
}

.cta-btns { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; margin-bottom: 48px; }

.cta-btn-main {
  display: inline-flex; align-items: center; gap: 10px;
  background: linear-gradient(135deg, #16a34a, #22c55e);
  color: white; text-decoration: none;
  padding: 17px 36px; border-radius: 50px;
  font-size: 16px; font-weight: 700;
  transition: .3s;
  box-shadow: 0 8px 30px rgba(22,163,74,0.4);
}
.cta-btn-main:hover { transform: translateY(-3px); box-shadow: 0 14px 40px rgba(22,163,74,0.5); }

.cta-btn-ghost {
  display: inline-flex; align-items: center; gap: 10px;
  background: rgba(255,255,255,0.08);
  border: 1px solid rgba(255,255,255,0.2);
  color: white; text-decoration: none;
  padding: 17px 36px; border-radius: 50px;
  font-size: 16px; font-weight: 600;
  transition: .3s;
}
.cta-btn-ghost:hover { background: rgba(255,255,255,0.14); transform: translateY(-3px); }

.trust-row   { display: flex; align-items: center; justify-content: center; gap: 24px; flex-wrap: wrap; }
.trust-item  { display: flex; align-items: center; gap: 8px; color: rgba(255,255,255,0.5); font-size: 13px; font-weight: 500; }
.trust-divider { width: 1px; height: 16px; background: rgba(255,255,255,0.12); }

/* ─── ANIMATIONS ─── */
@keyframes fadeUp   { from { opacity: 0; transform: translateY(24px); } to { opacity: 1; transform: translateY(0); } }
@keyframes fadeLeft { from { opacity: 0; transform: translateX(40px); } to { opacity: 1; transform: translateX(0); } }

/* ─── RESPONSIVE ─── */
@media (max-width: 900px) {
  .hero { grid-template-columns: 1fr; padding: 100px 5% 60px; text-align: center; }
  h1 { font-size: 40px; }
  .hero-desc { margin: 0 auto 36px; }
  .hero-btns { justify-content: center; }
  .hero-right { margin-top: 40px; }
  .pf1, .pf2, .pf3 { display: none; }
  .section-title { font-size: 30px; }
  .cta-title { font-size: 32px; }
  .cta-btns { flex-direction: column; align-items: center; }
}
</style>