```vue
<script setup>
import { useRouter } from "vue-router";
import NavbarView from "./NavbarView.vue";
import FooterView from "./FooterView.vue";

const router = useRouter();

const goToInstall = () => {
  router.push("/install");
};

const goToPanduan = () => {
  router.push("/panduan");
};
</script>

<template>

  <!-- REUSABLE NAVBAR -->
  <NavbarView />

  <!-- HERO -->
  <section class="landing">

    <!-- LEFT -->
    <div class="hero-left">

      <div class="badge">
        🚀 Aplikasi Pengingat Obat Modern
      </div>

      <h1>
        Jangan Pernah
        <br />
        Lupa Minum
        <br />
        Obat Bersama
        <span class="green">PilTime</span>
      </h1>

      <p>
        Pengingat minum obat yang hangat,
        sederhana, dan mudah digunakan
        untuk membantu lansia menjaga
        kesehatan setiap hari.
      </p>

      <div class="hero-buttons">

        <button
          class="primary-btn"
          @click="goToInstall"
        >
          ⬇ Download Gratis
        </button>

        <button
          class="secondary-btn"
          @click="goToPanduan"
        >
          🎥 Lihat Demo
        </button>

      </div>

    </div>

    <!-- RIGHT -->
    <div class="hero-right">

      <div class="phone-scene">

        <div class="circle-bg"></div>

        <div class="phone-wrapper">

          <div class="phone-shadow"></div>

          <div class="phone">

            <div class="notch"></div>

            <div class="phone-screen">

              <!-- TOP -->
              <div class="phone-top">

                <div>
                  <div class="hello">
                    Selamat Siang ☀️
                  </div>

                  <div class="username">
                    Hikzha Cristian
                  </div>
                </div>

                <div class="notif">
                  🔔
                </div>

              </div>

              <!-- CARD -->
              <div class="hero-card">

                <div class="hero-label">
                  KEPATUHAN HARI INI
                </div>

                <div class="hero-value">
                  1 dari 2 Selesai
                </div>

                <div class="hero-line"></div>

                <div class="hero-desc">
                  Ayo selesaikan sesi malam ya! 🌙
                </div>

              </div>

              <!-- MENU -->
              <div class="menu-title">
                Menu Utama
              </div>

              <div class="menu-grid">

                <div class="menu-item">
                  <div class="menu-icon">🔔</div>
                  <div class="menu-text">
                    Reminder Kelola
                  </div>
                </div>

                <div class="menu-item">
                  <div class="menu-icon">💊</div>
                  <div class="menu-text">
                    Info Obat
                  </div>
                </div>

                <div class="menu-item">
                  <div class="menu-icon">📈</div>
                  <div class="menu-text">
                    Riwayat Kepatuhan
                  </div>
                </div>

                <div class="menu-item">
                  <div class="menu-icon">❤️</div>
                  <div class="menu-text">
                    Rutinitas Sehat
                  </div>
                </div>

              </div>

              <!-- BOTTOM NAV -->
              <div class="bottom-nav">

                <div class="nav-item active">
                  🏠
                </div>

                <div class="add-btn">
                  +
                </div>

                <div class="nav-item">
                  👤
                </div>

              </div>

            </div>
          </div>
        </div>

      </div>

    </div>

  </section>

  <!-- FEATURES -->
  <section class="feature-list">

    <div class="feature">

      <div class="icon-3d">
        🔔
      </div>

      <div class="feature-text">

        <small>
          01 — REMINDER & ALARM
        </small>

        <h3>
          Tidak akan terlewat satu pun dosis
        </h3>

        <p>
          Alarm pintar untuk membantu
          pengguna minum obat tepat waktu.
        </p>

      </div>

    </div>

    <div class="feature reverse">

      <div class="icon-3d">
        💊
      </div>

      <div class="feature-text">

        <small>
          02 — INFO OBAT
        </small>

        <h3>
          Panduan obat di ujung jari
        </h3>

        <p>
          Informasi obat lengkap dan mudah
          dipahami untuk semua usia.
        </p>

      </div>

    </div>

    <div class="feature">

      <div class="icon-3d">
        📈
      </div>

      <div class="feature-text">

        <small>
          03 — RIWAYAT
        </small>

        <h3>
          Pantau kemajuan setiap hari
        </h3>

        <p>
          Lihat progres kepatuhan obat
          dengan tampilan realtime.
        </p>

      </div>

    </div>

    <div class="feature reverse">

      <div class="icon-3d">
        ❤️
      </div>

      <div class="feature-text">

        <small>
          04 — RUTINITAS
        </small>

        <h3>
          Bangun kebiasaan sehat
        </h3>

        <p>
          Membantu pengguna menjaga
          rutinitas sehat setiap hari.
        </p>

      </div>

    </div>

  </section>

  <FooterView />

</template>

<style scoped>

/* =========================
   GLOBAL
========================= */

.green {
  color: #1D9E75;
}

/* =========================
   HERO
========================= */

.landing {
  min-height: 100vh;

  display: flex;
  align-items: center;
  gap: 60px;

  padding: 40px 8% 80px;
}

.hero-left {
  flex: 1;
}

.badge {
  display: inline-block;

  padding: 10px 18px;

  border-radius: 999px;

  background: #e9faf3;

  color: #1D9E75;

  font-size: 14px;
  font-weight: 700;

  margin-bottom: 24px;
}

.hero-left h1 {
  font-size: 72px;
  line-height: 1.05;

  font-weight: 900;

  color: #0f172a;

  margin-bottom: 24px;
}

.hero-left p {
  max-width: 540px;

  font-size: 18px;
  line-height: 1.8;

  color: #64748b;

  margin-bottom: 32px;
}

.hero-buttons {
  display: flex;
  gap: 16px;
}

.primary-btn {
  border: none;

  padding: 16px 28px;

  border-radius: 16px;

  background: linear-gradient(
    135deg,
    #1D9E75,
    #0F6E56
  );

  color: white;

  font-size: 15px;
  font-weight: 700;

  cursor: pointer;

  transition: 0.3s;
}

.primary-btn:hover {
  transform: translateY(-3px);
}

.secondary-btn {
  border: 2px solid #1D9E75;

  padding: 16px 28px;

  border-radius: 16px;

  background: transparent;

  color: #1D9E75;

  font-size: 15px;
  font-weight: 700;

  cursor: pointer;

  transition: 0.3s;
}

.secondary-btn:hover {
  background: #1D9E75;
  color: white;
}

/* =========================
   PHONE
========================= */

.hero-right {
  flex: 1;

  display: flex;
  justify-content: center;
}

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

  border-radius: 50%;

  background: linear-gradient(
    135deg,
    #eef8f3,
    #dff4ea
  );
}

.phone-wrapper {
  position: relative;
  z-index: 2;

  transform: rotate(6deg);
}

.phone-shadow {
  position: absolute;
  inset: 0;

  border-radius: 50px;

  background: rgba(0,0,0,0.15);

  filter: blur(40px);

  transform: translateY(40px);
}

.phone {
  width: 260px;
  height: 540px;

  padding: 10px;

  border-radius: 42px;

  background: #111827;
}

.notch {
  position: absolute;

  top: 14px;
  left: 50%;

  transform: translateX(-50%);

  width: 100px;
  height: 24px;

  border-radius: 999px;

  background: #020617;
}

.phone-screen {
  width: 100%;
  height: 100%;

  padding: 36px 16px 16px;

  border-radius: 34px;

  background: white;

  overflow: hidden;

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
  color: #64748b;
}

.username {
  font-size: 18px;
  font-weight: 800;
}

.notif {
  width: 38px;
  height: 38px;

  border-radius: 50%;

  display: flex;
  justify-content: center;
  align-items: center;

  background: #f1f5f9;
}

.hero-card {
  padding: 20px;

  border-radius: 22px;

  color: white;

  background: linear-gradient(
    135deg,
    #1D9E75,
    #0F6E56
  );
}

.hero-label {
  font-size: 10px;
  font-weight: 700;
}

.hero-value {
  margin-top: 8px;

  font-size: 26px;
  font-weight: 800;
}

.hero-line {
  width: 100%;
  height: 5px;

  margin: 14px 0;

  border-radius: 999px;

  background: rgba(255,255,255,0.3);
}

.hero-desc {
  font-size: 13px;
}

.menu-title {
  margin-top: 18px;
  margin-bottom: 12px;

  font-size: 15px;
  font-weight: 800;
}

.menu-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;

  gap: 10px;
}

.menu-item {
  padding: 14px;

  border-radius: 18px;

  background: white;

  box-shadow:
    0 8px 20px rgba(0,0,0,0.05);

  transition: 0.3s;
}

.menu-item:hover {
  transform: translateY(-4px);
}

.menu-icon {
  font-size: 22px;
  margin-bottom: 8px;
}

.menu-text {
  font-size: 12px;
  font-weight: 700;
}

.bottom-nav {
  position: absolute;

  left: 14px;
  right: 14px;
  bottom: 12px;

  padding: 8px 16px;

  border-radius: 20px;

  display: flex;
  justify-content: space-between;
  align-items: center;

  background: rgba(255,255,255,0.92);
}

.add-btn {
  width: 50px;
  height: 50px;

  margin-top: -30px;

  border-radius: 50%;

  display: flex;
  justify-content: center;
  align-items: center;

  background: linear-gradient(
    135deg,
    #1D9E75,
    #0F6E56
  );

  color: white;

  font-size: 28px;
  font-weight: 800;
}

/* =========================
   FEATURES
========================= */

.feature-list {
  display: flex;
  flex-direction: column;

  gap: 80px;

  padding: 80px 8%;
}

.feature {
  display: flex;
  align-items: center;
  gap: 60px;
}

.reverse {
  flex-direction: row-reverse;
}

.icon-3d {
  width: 90px;
  height: 90px;

  border-radius: 24px;

  display: flex;
  justify-content: center;
  align-items: center;

  font-size: 34px;

  background: linear-gradient(
    145deg,
    #ffffff,
    #eef8f3
  );

  box-shadow:
    0 25px 60px rgba(0,0,0,0.12);

  transition: 0.3s;
}

.feature:hover .icon-3d {
  transform:
    translateY(-10px)
    scale(1.08);
}

.feature-text small {
  color: #1D9E75;

  font-size: 11px;
  font-weight: 800;

  letter-spacing: 1.5px;
}

.feature-text h3 {
  margin: 8px 0;

  font-size: 30px;
  font-weight: 900;

  color: #0f172a;
}

.feature-text p {
  max-width: 520px;

  line-height: 1.8;

  color: #64748b;
}

/* =========================
   RESPONSIVE
========================= */

@media (max-width: 1024px) {

  .landing {
    flex-direction: column;
    text-align: center;
  }

  .hero-buttons {
    justify-content: center;
  }

  .hero-left h1 {
    font-size: 54px;
  }

}

@media (max-width: 768px) {

  .landing {
    padding: 40px 5%;
  }

  .feature,
  .reverse {
    flex-direction: column;
    text-align: center;
  }

  .hero-left h1 {
    font-size: 42px;
  }

}
</style>
```
