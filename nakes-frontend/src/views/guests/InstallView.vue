<template>

  <div class="install-page">

    <!-- NAVBAR -->
    <NavbarView />

    <!-- HERO -->
    <section class="hero">

      <div class="overlay"></div>

      <div class="hero-content">

        <span class="badge">
          📱 Download Aplikasi
        </span>

        <h1>
          Unduh <span>Pil Time</span>
        </h1>

        <p>
          Pil Time adalah aplikasi pengingat minum obat yang membantu pasien
          mengatur jadwal konsumsi obat, meningkatkan kepatuhan pengobatan,
          serta memastikan terapi berjalan tepat waktu dan konsisten.
        </p>

        <div class="button-group">

          <a href="/apk/piltime.apk" download class="download-btn">
            📥 Download APK
          </a>

          <a href="#fitur" class="secondary-btn">
            Lihat Fitur
          </a>

        </div>

      </div>

    </section>

    <!-- INFO APP -->
    <section class="section">

      <div class="container">

        <div class="app-preview">

          <!-- PHONE -->
          <div class="phone-mockup">

            <div class="screen">

              <h2>Pil Time</h2>

              <div class="mock-card">
                <p>Kepatuhan Hari Ini</p>
                <h3>1 / 2 Dosis</h3>
              </div>

              <div class="mock-card">
                <p>Reminder Aktif</p>
                <h3>3 Obat</h3>
              </div>

              <div class="mock-card">
                <p>Tingkat Kepatuhan</p>
                <h3>78%</h3>
              </div>

            </div>

          </div>

          <!-- TEXT -->
          <div class="app-text">

            <span class="section-badge">
              TENTANG APLIKASI
            </span>

            <h2>
              Aplikasi Pengingat Obat Modern
            </h2>

            <p>
              Pil Time membantu pasien, keluarga, dan tenaga kesehatan
              dalam mengelola jadwal konsumsi obat secara otomatis
              dan terstruktur.
            </p>

            <p>
              Dengan sistem pengingat cerdas, aplikasi ini memastikan
              setiap dosis obat diminum tepat waktu tanpa terlewat.
            </p>

            <ul>
              <li>✔ Reminder Minum Obat Otomatis</li>
              <li>✔ Riwayat Kepatuhan Harian</li>
              <li>✔ Informasi & Jadwal Obat</li>
              <li>✔ Monitoring Kesehatan Pasien</li>
              <li>✔ UI Sederhana & Mudah Digunakan</li>
            </ul>

          </div>

        </div>

      </div>

    </section>

    <!-- FITUR -->
    <section class="section bg-light" id="fitur">

      <div class="container">

        <div class="section-title">

          <span>FITUR UNGGULAN</span>

          <h2>Kenapa Pil Time?</h2>

        </div>

        <div class="feature-grid">

  <div class="feature-card">
    <div class="icon">⏰</div>
    <h3>Reminder Obat</h3>
    <p>
      Sistem pengingat otomatis yang memastikan pasien tidak pernah melewatkan jadwal minum obat,
      baik pagi, siang, maupun malam.
    </p>
  </div>

  <div class="feature-card">
    <div class="icon">💊</div>
    <h3>Info & Dosis Obat</h3>
    <p>
      Menyediakan informasi lengkap tentang nama obat, fungsi, dosis yang tepat,
      serta cara penggunaan yang benar.
    </p>
  </div>

  <div class="feature-card">
    <div class="icon">📊</div>
    <h3>Riwayat Kepatuhan</h3>
    <p>
      Menyimpan catatan konsumsi obat harian sehingga pasien dan tenaga medis
      dapat memantau tingkat kepatuhan secara akurat.
    </p>
  </div>

  <div class="feature-card">
    <div class="icon">🏥</div>
    <h3>Monitoring Kesehatan</h3>
    <p>
      Memantau kondisi kesehatan pasien secara digital untuk membantu evaluasi
      efektivitas pengobatan.
    </p>
  </div>

  <div class="feature-card">
    <div class="icon">🔔</div>
    <h3>Notifikasi Pintar</h3>
    <p>
      Notifikasi adaptif berbasis jadwal pasien agar pengingat lebih relevan,
      tidak mengganggu, dan tetap konsisten.
    </p>
  </div>

  <div class="feature-card">
    <div class="icon">👨‍⚕️</div>
    <h3>Dashboard Tenaga Medis</h3>
    <p>
      Memungkinkan dokter atau perawat memantau kepatuhan pasien secara real-time
      untuk meningkatkan kualitas perawatan.
    </p>
  </div>

</div>

      </div>

    </section>

    <!-- CTA -->
    <section class="cta-section">

      <div class="container cta-content">

        <h2>
          Mulai Lebih Disiplin Minum Obat
        </h2>

        <p>
          Unduh Pil Time sekarang dan jaga kesehatanmu dengan lebih mudah,
          teratur, dan terkontrol setiap hari.
        </p>

        <a href="/apk/piltime.apk" download class="download-btn large">
          🚀 Download Sekarang
        </a>

      </div>

    </section>

  </div>

</template>

<script>

import NavbarView from './NavbarView.vue'

export default {
  name: "InstallView",

  components: {
    NavbarView
  }
}

</script>

<style scoped>

*{
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.install-page{
  font-family: "Poppins", sans-serif;
  background: #ffffff;
  color: #0f172a;
}

/* ================= HERO ================= */
.hero{
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;

  padding: 120px 20px;
  background: linear-gradient(135deg, #4ace7b, #74b78d);
  overflow: hidden;
}

.overlay{
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,0.25);
}

.hero-content{
  position: relative;
  z-index: 2;
  text-align: center;
  color: white;
  max-width: 850px;
  animation: fadeUp 0.8s ease;
}

.badge{
  display: inline-block;
  background: rgba(255,255,255,0.15);
  padding: 10px 18px;
  border-radius: 50px;
  font-size: 14px;
  font-weight: 600;
  backdrop-filter: blur(10px);
  margin-bottom: 20px;
}

.hero-content h1{
  font-size: 64px;
  font-weight: 800;
  margin-bottom: 18px;
}

.hero-content h1 span{
  color: #fff;
}

.hero-content p{
  font-size: 18px;
  line-height: 1.8;
  margin-bottom: 30px;
  opacity: 0.95;
}

/* ================= BUTTON ================= */
.button-group{
  display: flex;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}

.download-btn{
  background: #fff;
  color: #16a34a;
  padding: 14px 30px;
  border-radius: 50px;
  font-weight: 700;
  text-decoration: none;
  transition: 0.3s;
  box-shadow: 0 10px 25px rgba(0,0,0,0.15);
}

.download-btn:hover{
  transform: translateY(-4px);
  background: #f0fdf4;
}

.secondary-btn{
  border: 2px solid white;
  color: white;
  padding: 14px 30px;
  border-radius: 50px;
  text-decoration: none;
  font-weight: 600;
  transition: 0.3s;
}

.secondary-btn:hover{
  background: white;
  color: #16a34a;
  transform: translateY(-4px);
}

/* ================= SECTION ================= */
.section{
  padding: 90px 20px;
}

.bg-light{
  background: #f8fafc;
}

.container{
  max-width: 1200px;
  margin: auto;
}

.section-title{
  text-align: center;
  margin-bottom: 60px;
}

.section-title span{
  color: #16a34a;
  font-weight: 600;
  letter-spacing: 2px;
  font-size: 13px;
}

.section-title h2{
  font-size: 40px;
  margin-top: 10px;
  font-weight: 800;
}

/* ================= APP PREVIEW ================= */
.app-preview{
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 60px;
  align-items: center;
}

/* ================= PHONE MOCKUP ================= */
.phone-mockup{
  width: 280px;
  height: 560px;
  background: #0f172a;
  border-radius: 42px;
  padding: 12px;
  margin: auto;
  box-shadow: 0 25px 60px rgba(0,0,0,0.25);
  position: relative;
  transition: 0.4s;
}

.phone-mockup:hover{
  transform: translateY(-8px) rotate(-1deg);
}

.screen{
  width: 100%;
  height: 100%;
  border-radius: 32px;
  background: linear-gradient(160deg, #f0faf5, #e0f2fe);
  padding: 24px 16px;
  overflow: hidden;
}

.screen h2{
  text-align: center;
  margin-bottom: 20px;
  font-weight: 800;
  color: #16a34a;
}

/* CARD MOCK */
.mock-card{
  background: white;
  padding: 16px;
  border-radius: 16px;
  margin-bottom: 14px;
  box-shadow: 0 6px 18px rgba(0,0,0,0.06);
  transition: 0.3s;
}

.mock-card:hover{
  transform: scale(1.05);
}

.mock-card p{
  font-size: 12px;
  color: #64748b;
}

.mock-card h3{
  margin-top: 6px;
  font-size: 18px;
  color: #0f172a;
}

/* ================= TEXT ================= */
.section-badge{
  color: #16a34a;
  font-weight: 700;
  letter-spacing: 2px;
  font-size: 12px;
}

.app-text h2{
  font-size: 38px;
  margin: 16px 0;
  font-weight: 800;
}

.app-text p{
  color: #475569;
  line-height: 1.9;
  margin-bottom: 16px;
}

.app-text ul{
  list-style: none;
  margin-top: 20px;
}

.app-text li{
  margin-bottom: 12px;
  font-size: 15px;
  color: #334155;
}

/* ================= FEATURES ================= */
.feature-grid{
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 22px;
}

.feature-card{
  background: white;
  padding: 28px;
  border-radius: 20px;
  text-align: center;
  box-shadow: 0 10px 25px rgba(0,0,0,0.05);
  transition: 0.4s;
}

.feature-card:hover{
  transform: translateY(-8px);
  box-shadow: 0 18px 40px rgba(22,163,74,0.15);
}

.icon{
  font-size: 42px;
  margin-bottom: 14px;
}

.feature-card h3{
  color: #16a34a;
  margin-bottom: 10px;
}

.feature-card p{
  color: #64748b;
  font-size: 14px;
  line-height: 1.6;
}

/* ================= CTA ================= */
.cta-section{
  padding: 110px 20px;
  background: linear-gradient(135deg, #16a34a, #22c55e);
  text-align: center;
  color: white;
}

.cta-content{
  max-width: 800px;
  margin: auto;
}

.cta-content h2{
  font-size: 42px;
  margin-bottom: 20px;
  font-weight: 800;
}

.cta-content p{
  font-size: 17px;
  line-height: 1.8;
  margin-bottom: 30px;
  opacity: 0.95;
}

.large{
  font-size: 16px;
  padding: 16px 34px;
}

/* ================= ANIMATION ================= */
@keyframes fadeUp{
  from{
    opacity: 0;
    transform: translateY(30px);
  }
  to{
    opacity: 1;
    transform: translateY(0);
  }
}

/* ================= RESPONSIVE ================= */
@media(max-width: 900px){
  .app-preview{
    grid-template-columns: 1fr;
    text-align: center;
  }

  .feature-grid{
    grid-template-columns: repeat(2, 1fr);
  }

  .hero-content h1{
    font-size: 42px;
  }

  .app-text h2{
    font-size: 30px;
  }
}

@media(max-width: 600px){
  .feature-grid{
    grid-template-columns: 1fr;
  }
}

</style>