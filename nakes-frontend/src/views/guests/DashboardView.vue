<script setup>
import { Bell, Pill, BarChart3, Heart } from "@lucide/vue";
</script>
<template>


  <!-- NAVBAR -->
  <nav class="navbar">
    <div class="logo">
      <div class="logo-box">💊</div>
      <span>Pil<span class="green">Time</span></span>
    </div>

    <div class="nav-links">
      <a href="#">Dashboard</a>
      <a href="#">Tentang</a>
      <a href="#">Install</a>
      <a href="#">Panduan</a>
    </div>

    <button class="login-btn">Login</button>
  </nav>

  <!-- HERO SECTION -->
  <div class="landing">

    <!-- LEFT -->
    <div class="hero-left">

      <h1>
        Jangan Pernah
        <br />
        Lupa Minum
        <br />
        Obat Bersama
        <span class="green">PilTime</span>
      </h1>

      <p>
        Pengingat minum obat yang hangat, sederhana, dan mudah digunakan
        untuk membantu lansia menjaga kesehatan setiap hari dengan lebih tenang.
      </p>


      <div class="hero-buttons">
        <button class="primary-btn">⬇ Download Gratis</button>
        <button class="secondary-btn">🎥 Lihat Demo</button>
      </div>

    </div>

    <!-- RIGHT -->
    <div class="hero-right">

      <div class="phone-scene">

        <!-- PHONE -->
        <div class="phone-wrapper">

          <div class="phone-shadow"></div>

          <div class="phone">

            <div class="notch"></div>

            <div class="phone-screen">

              <!-- TOP -->
              <div class="phone-top">
                <div>
                  <div class="hello">Selamat Siang ☀️</div>
                  <div class="username">Hikzha Cristian</div>
                </div>
                <div class="notif">🔔</div>
              </div>

              <!-- CARD -->
              <div class="hero-card">
                <div class="hero-label">KEPATUHAN HARI INI</div>
                <div class="hero-value">1 dari 2 Selesai</div>
                <div class="hero-line"></div>
                <div class="hero-desc">Ayo selesaikan sesi malam ya! 🌙</div>
              </div>

              <!-- MENU -->
              <div class="menu-title">Menu Utama</div>

              <div class="menu-grid">
                <div class="menu-item">
                  <div class="menu-icon">🔔</div>
                  <div class="menu-text">Reminder Kelola</div>
                </div>
                <div class="menu-item">
                  <div class="menu-icon">💊</div>
                  <div class="menu-text">Info Obat</div>
                </div>
                <div class="menu-item">
                  <div class="menu-icon">📈</div>
                  <div class="menu-text">Riwayat Kepatuhan</div>
                </div>
                <div class="menu-item">
                  <div class="menu-icon">❤️</div>
                  <div class="menu-text">Rutinitas Sehat</div>
                </div>
              </div>

              <!-- BOTTOM NAV -->
              <div class="bottom-nav">
                <div class="nav-item active">🏠</div>
                <div class="add-btn">+</div>
                <div class="nav-item">👤</div>
              </div>

            </div>
          </div>
        </div>

        <!-- BG CIRCLE -->
        <div class="circle-bg"></div>

      </div>
    </div>

  </div>
  <!-- END LANDING -->

  <!-- FEATURES -->
<div class="feature-list">

  <div class="feature reminder">
    <div class="icon-3d reminder-icon">
      🔔
    </div>
    <div class="feature-text">
      <small>01 — REMINDER & ALARM</small>
      <h3>Tidak akan terlewat satu pun dosis</h3>
      <p>Alarm pintar untuk membantu pengguna minum obat tepat waktu setiap hari.</p>
    </div>
  </div>

  <div class="feature info-obat">
    <div class="icon-3d info-icon">
      💊
    </div>
    <div class="feature-text">
      <small>02 — INFO OBAT</small>
      <h3>Panduan obat di ujung jari</h3>
      <p>Informasi obat lengkap dan sederhana agar mudah dipahami semua usia.</p>
    </div>
  </div>

  <div class="feature riwayat">
    <div class="icon-3d chart-icon">
      📊
    </div>
    <div class="feature-text">
      <small>03 — RIWAYAT</small>
      <h3>Pantau kemajuan setiap hari</h3>
      <p>Lihat progres kepatuhan obat secara realtime dengan tampilan sederhana.</p>
    </div>
  </div>

  <div class="feature rutinitas">
    <div class="icon-3d heart-icon">
      ❤️
    </div>
    <div class="feature-text">
      <small>04 — RUTINITAS</small>
      <h3>Bangun kebiasaan sehat</h3>
      <p>Bantu pengguna menjaga rutinitas sehat setiap hari dengan mudah.</p>
    </div>
  </div>

</div>


  <!-- FOOTER -->
  <footer class="footer">

    <div class="footer-container">

      <!-- LEFT -->
      <div class="footer-brand">

        <div class="footer-logo">
          <div class="footer-logo-box">💊</div>
          <span>Pil<span class="green">Time</span></span>
        </div>

        <p>
          PilTime membantu lansia dan keluarga
          menjaga jadwal minum obat agar tetap
          teratur, tepat waktu, dan lebih sehat
          setiap hari.
        </p>

        <div class="footer-socials">
          <span>🌐</span>
          <span>📱</span>
          <span>✉️</span>
        </div>

      </div>

      <!-- MENU -->
      <div class="footer-links">

        <div class="footer-column">
          <h4>Navigasi</h4>
          <a href="#">Dashboard</a>
          <a href="#">Tentang</a>
          <a href="#">Fitur</a>
          <a href="#">Panduan</a>
        </div>

        <div class="footer-column">
          <h4>Fitur</h4>
          <a href="#">Reminder Obat</a>
          <a href="#">Info Obat</a>
          <a href="#">Riwayat Kepatuhan</a>
          <a href="#">Rutinitas Sehat</a>
        </div>

        <div class="footer-column">
          <h4>Kontak</h4>
          <a href="#">piltime@gmail.com</a>
          <a href="#">+62 812-3456-7890</a>
          <a href="#">Medan, Indonesia</a>
        </div>

      </div>

    </div>

    <!-- BOTTOM -->
    <div class="footer-bottom">
      <p>© 2026 PilTime. Semua Hak Dilindungi.</p>
      <div class="footer-bottom-links">
        <a href="#">Privacy Policy</a>
        <a href="#">Terms</a>
      </div>
    </div>

  </footer>

</template>

<style scoped>

/* ============================
   NAVBAR
   ============================ */
.icon-3d {
  width: 90px;
  height: 90px;

  display: flex;
  align-items: center;
  justify-content: center;

  font-size: 34px;

  border-radius: 24px;

  background: linear-gradient(145deg, #ffffff, #eef8f3);

  box-shadow:
    0 25px 60px rgba(0,0,0,0.12),
    inset 0 2px 10px rgba(255,255,255,0.9);

  transform: perspective(800px) rotateX(10deg) rotateY(-10deg);

  transition: all 0.4s ease;
}

/* hover premium */
.feature:hover .icon-3d {
  transform: perspective(800px) rotateX(0deg) rotateY(0deg)
    translateY(-10px) scale(1.08);

  box-shadow: 0 40px 90px rgba(0,0,0,0.18);
}

/* warna tiap icon */
.reminder-icon { color: #ff4d6d; }
.info-icon     { color: #1D9E75; }
.chart-icon    { color: #3b82f6; }
.heart-icon    { color: #ef4444; }

.navbar {
  width: 100%;
  height: 100px;
  padding: 0 8%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(18px);
  position: sticky;
  top: 0;
  z-index: 100;
  border-bottom: 1px solid #edf1ef;
  transition: all 0.3s ease;
}

.logo {
  display: flex;
  align-items: center;
  gap: 14px;
  font-size: 30px;
  font-weight: 900;
}

.logo-box {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  background: #e9faf3;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
}

.green {
  color: #1D9E75;
}

.nav-links {
  display: flex;
  gap: 50px;
}

.nav-links a {
  text-decoration: none;
  color: #333;
  font-size: 18px;
  font-weight: 600;
  position: relative;
  transition: 0.3s;
}

.nav-links a::after {
  content: "";
  position: absolute;
  left: 0;
  bottom: -6px;
  width: 0%;
  height: 2px;
  background: #1D9E75;
  transition: 0.3s;
}

.nav-links a:hover { color: #1D9E75; }
.nav-links a:hover::after { width: 100%; }

.login-btn {
  border: none;
  background: #1D9E75;
  color: white;
  padding: 16px 34px;
  border-radius: 16px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 10px 25px rgba(29, 158, 117, 0.25);
  transition: 0.3s;
}

.login-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 15px 35px rgba(29, 158, 117, 0.35);
}


/* ============================
   HERO / LANDING
   ============================ */
.landing {
  display: flex;
  align-items: center;
  gap: 40px;
  /* Hapus padding atas agar menempel ke navbar */
  padding: 0 8% 60px; 
  min-height: auto; /* Hilangkan calc agar tidak memaksa tinggi */
}

/* LEFT */
.hero-left {
  flex: 1;
  animation: floatHero 6s ease-in-out infinite;
}

.hero-left > * {
  opacity: 0;
  transform: translateY(20px);
  animation: fadeUp 0.8s ease forwards;
}

.badge          { animation-delay: 0.1s; }
.hero-left h1   { animation-delay: 0.2s; }
.hero-left p    { animation-delay: 0.3s; }
.hero-stats     { animation-delay: 0.4s; }
.hero-buttons   { animation-delay: 0.5s; }

.badge {
  display: inline-block;
  background: linear-gradient(135deg, #e9faf3, #dff4ea);
  color: #1D9E75;
  padding: 10px 18px;
  border-radius: 30px;
  margin-bottom: 24px;
  font-size: 14px;
  font-weight: 700;
  box-shadow: 0 8px 20px rgba(29, 158, 117, 0.1);
}

.hero-left h1 {
  font-size: 72px;
  line-height: 1.05;
  font-weight: 900;
  letter-spacing: -1px;
  margin-bottom: 24px;
  animation: fadeUp 0.8s ease forwards, glowText 3s ease-in-out infinite;
}

.hero-left p {
  max-width: 520px;
  line-height: 1.8;
  color: #5f736b;
  font-size: 18px;
  margin-bottom: 28px;
}

/* STATS */
.hero-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 28px;
  flex-wrap: wrap;
}

.stat {
  background: white;
  padding: 14px 18px;
  border-radius: 16px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.06);
  min-width: 120px;
  cursor: pointer;
  transition: 0.3s;
}

.stat:hover {
  transform: translateY(-8px) scale(1.05);
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.12);
}

.stat h3 {
  font-size: 20px;
  color: #1D9E75;
  margin-bottom: 4px;
}

.stat span {
  font-size: 13px;
  color: #6b7280;
}

/* BUTTONS */
.hero-buttons {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.primary-btn {
  background: #1D9E75;
  color: white;
  border: none;
  padding: 14px 28px;
  border-radius: 14px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: 0.3s ease;
  position: relative;
  overflow: hidden;
  box-shadow: 0 10px 25px rgba(29, 158, 117, 0.3);
}

.primary-btn::after {
  content: "";
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: -100%;
  background: rgba(255, 255, 255, 0.25);
  transform: skewX(-20deg);
  transition: 0.5s;
}

.primary-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 15px 35px rgba(29, 158, 117, 0.4);
}

.primary-btn:hover::after { left: 100%; }

.secondary-btn {
  background: transparent;
  color: #1D9E75;
  border: 2px solid #1D9E75;
  padding: 14px 28px;
  border-radius: 14px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: 0.3s ease;
}

.secondary-btn:hover {
  background: #1D9E75;
  color: white;
  transform: translateY(-3px);
}

/* RIGHT */
.hero-right {
  flex: 1;
  display: flex;
  justify-content: flex-end;
  align-items: center;
}


/* ============================
   PHONE MOCKUP
   ============================ */
.phone-scene {
  position: relative;
  width: 340px;
  height: 580px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.circle-bg {
  position: absolute;
  width: 360px;
  height: 360px;
  background: linear-gradient(135deg, #eef8f3, #dff4ea);
  border-radius: 50%;
  z-index: 0;
}

.phone-wrapper {
  position: relative;
  z-index: 2;
  transform: rotate(6deg);
  animation: floatPhone 5s ease-in-out infinite;
}

.phone-shadow {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.12);
  filter: blur(40px);
  transform: translateY(40px) scale(0.9);
  border-radius: 50px;
  z-index: -1;
}

.phone {
  width: 260px;
  height: 540px;
  background: #111827;
  border-radius: 42px;
  padding: 10px;
  position: relative;
  box-shadow:
    0 25px 60px rgba(0, 0, 0, 0.25),
    inset 0 0 0 2px rgba(255, 255, 255, 0.05);
}

.notch {
  position: absolute;
  top: 14px;
  left: 50%;
  transform: translateX(-50%);
  width: 100px;
  height: 24px;
  background: #020617;
  border-radius: 30px;
  z-index: 10;
}

.phone-screen {
  width: 100%;
  height: 100%;
  background: white;
  border-radius: 34px;
  overflow: hidden;
  padding: 36px 16px 16px;
  position: relative;
}

.phone-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.hello {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.username {
  font-size: 18px;
  font-weight: 800;
  color: #0f172a;
  margin-top: 2px;
}

.notif {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: #f3f4f6;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
}

.hero-card {
  background: linear-gradient(135deg, #1D9E75, #0F6E56);
  border-radius: 22px;
  padding: 20px;
  color: white;
  box-shadow: 0 15px 35px rgba(29, 158, 117, 0.3);
}

.hero-label {
  font-size: 10px;
  font-weight: 700;
  opacity: 0.85;
  letter-spacing: 1px;
}

.hero-value {
  margin-top: 8px;
  font-size: 26px;
  line-height: 1.1;
  font-weight: 800;
}

.hero-line {
  width: 100%;
  height: 5px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.35);
  margin: 14px 0;
}

.hero-desc {
  font-size: 13px;
  line-height: 1.5;
  font-weight: 600;
}

.menu-title {
  margin-top: 18px;
  margin-bottom: 12px;
  font-size: 15px;
  font-weight: 800;
  color: #111827;
}

.menu-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.menu-item {
  background: white;
  border-radius: 18px;
  padding: 14px;
  box-shadow:
    0 8px 20px rgba(0, 0, 0, 0.05),
    inset 0 0 0 1px #f1f5f9;
  transition: 0.25s ease;
  cursor: pointer;
}

.menu-item:hover { transform: translateY(-4px); }

.menu-icon {
  font-size: 22px;
  margin-bottom: 8px;
}

.menu-text {
  font-size: 12px;
  font-weight: 700;
  line-height: 1.4;
  color: #0f172a;
}

.bottom-nav {
  position: absolute;
  left: 14px;
  right: 14px;
  bottom: 12px;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(12px);
  border-radius: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.06);
}

.nav-item {
  font-size: 20px;
  opacity: 0.55;
}

.nav-item.active { opacity: 1; }

.add-btn {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: linear-gradient(135deg, #1D9E75, #0F6E56);
  color: white;
  font-size: 28px;
  font-weight: 700;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: -30px;
  box-shadow: 0 12px 24px rgba(29, 158, 117, 0.35);
}

.feature-list {
  display: flex;
  flex-direction: column;
  gap: 90px;
  max-width: 900px;
  margin: 0 auto;
  padding: 60px 20px;
}
/* =========================
   ROW LAYOUT (STARTUP PREMIUM ZIGZAG)
========================= */
/* =========================
   ROW LAYOUT (FULL EDGE STYLE)
========================= */
.reminder,
.info-obat,
.riwayat,
.rutinitas {
  display: flex;
  align-items: center;
  gap: 60px;

  width: 100%;
  padding: 60px 8%;

  transition: 0.3s ease;
}

/* =========================
   ZIGZAG FULL EDGE
========================= */

/* KIRI MELEKAT KE KIRI */
.reminder,
.riwayat {
  justify-content: flex-start;
}

/* KANAN MELEKAT KE KANAN */
.info-obat,
.rutinitas {
  justify-content: flex-end;
  flex-direction: row-reverse;
}

/* =========================
   ICON (3D PREMIUM)
========================= */
.feature-icon {
  width: 85px;
  height: 85px;

  display: flex;
  align-items: center;
  justify-content: center;

  font-size: 32px;

  border-radius: 22px;

  background: linear-gradient(145deg, #ffffff, #f4fbf8);

  box-shadow:
    0 20px 50px rgba(0,0,0,0.10),
    inset 0 2px 10px rgba(255,255,255,0.9);

  transform: perspective(800px) rotateX(8deg) rotateY(-8deg);

  transition: all 0.4s ease;
}

/* hover floating */
.reminder:hover .feature-icon,
.info-obat:hover .feature-icon,
.riwayat:hover .feature-icon,
.rutinitas:hover .feature-icon {
  transform: perspective(800px) rotateX(0deg) rotateY(0deg)
    translateY(-10px) scale(1.1);
  box-shadow: 0 40px 90px rgba(0,0,0,0.18);
}

/* =========================
   TEXT
========================= */
.feature-text small {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 1.8px;
  color: #1D9E75;
}

.feature-text h3 {
  font-size: 26px;
  font-weight: 900;
  color: #0f172a;
  margin: 8px 0;
}

.feature-text p {
  font-size: 15.5px;
  color: #5f736b;
  line-height: 1.8;
  max-width: 520px;
}

/* hover text */
.reminder:hover h3,
.info-obat:hover h3,
.riwayat:hover h3,
.rutinitas:hover h3 {
  color: #1D9E75;
  transition: 0.3s ease;
}

/* =========================
   MOBILE
========================= */
@media (max-width: 768px) {
  .reminder,
  .info-obat,
  .riwayat,
  .rutinitas {
    flex-direction: column !important;
    text-align: center;
    padding: 40px 6%;
    gap: 20px;
  }
}
/* ============================
   FOOTER
   ============================ */
.footer {
  background: #071d17;
  color: white;
  padding-top: 80px;
}

.footer-container {
  width: 100%;
  padding: 0 8% 60px;
  display: flex;
  justify-content: space-between;
  gap: 80px;
  flex-wrap: wrap;
}

.footer-brand {
  flex: 1;
  min-width: 280px;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 28px;
  font-weight: 800;
  margin-bottom: 24px;
}

.footer-logo-box {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
}

.footer-brand p {
  max-width: 420px;
  line-height: 1.9;
  color: #b8d7cd;
  font-size: 16px;
}

.footer-socials {
  display: flex;
  gap: 16px;
  margin-top: 28px;
}

.footer-socials span {
  width: 46px;
  height: 46px;
  border-radius: 14px;
  background: rgba(255, 255, 255, 0.08);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  cursor: pointer;
  transition: 0.3s;
}

.footer-socials span:hover {
  transform: translateY(-4px);
  background: #1D9E75;
}

.footer-links {
  display: flex;
  gap: 70px;
  flex-wrap: wrap;
}

.footer-column {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.footer-column h4 {
  font-size: 18px;
  margin-bottom: 10px;
  color: white;
}

.footer-column a {
  text-decoration: none;
  color: #b8d7cd;
  font-size: 15px;
  transition: 0.25s;
}

.footer-column a:hover {
  color: #1D9E75;
  transform: translateX(4px);
}

.footer-bottom {
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  padding: 24px 8%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.footer-bottom p {
  color: #b8d7cd;
  font-size: 14px;
}

.footer-bottom-links {
  display: flex;
  gap: 20px;
}

.footer-bottom-links a {
  text-decoration: none;
  color: #b8d7cd;
  font-size: 14px;
  transition: 0.25s;
}

.footer-bottom-links a:hover { color: #1D9E75; }


/* ============================
   ANIMATIONS
   ============================ */
@keyframes fadeUp {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes glowText {
  0%, 100% { text-shadow: 0 0 0 rgba(29, 158, 117, 0); }
  50%       { text-shadow: 0 10px 40px rgba(29, 158, 117, 0.25); }
}

@keyframes floatHero {
  0%, 100% { transform: translateY(0); }
  50%       { transform: translateY(-10px); }
}

@keyframes floatPhone {
  0%, 100% { transform: rotate(6deg) translateY(0); }
  50%       { transform: rotate(6deg) translateY(-14px); }
}


/* ============================
   RESPONSIVE
   ============================ */
@media (max-width: 1024px) {
  .landing {
    flex-direction: column;
    padding: 60px 6%;
    text-align: center;
  }

  .hero-left { animation: none; }
  .hero-right { justify-content: center; }
  .hero-stats { justify-content: center; }
  .hero-buttons { justify-content: center; }
  .hero-left p { margin: 0 auto 28px; }

  .hero-left h1 { font-size: 52px; }
}

@media (max-width: 768px) {
  .nav-links { display: none; }

  .hero-left h1 { font-size: 40px; }

  .feature-card,
  .feature-card.reverse {
    flex-direction: column;
    text-align: center;
  }

  .feature-card p { max-width: 100%; }

  .footer-container {
    flex-direction: column;
    gap: 50px;
  }

  .footer-links { gap: 40px; }

  .footer-bottom {
    flex-direction: column;
    text-align: center;
  }
}
</style>