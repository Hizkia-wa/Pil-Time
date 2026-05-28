```vue
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
          Kelola keuangan, bangun kebiasaan menabung,
          dan tingkatkan produktivitasmu dengan teknologi AI
          dalam satu aplikasi modern.
        </p>

        <div class="button-group">

          <a
            href="/apk/piltime.apk"
            download
            class="download-btn"
          >
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
                <p>Total Tabungan</p>
                <h3>Rp 2.500.000</h3>
              </div>

              <div class="mock-card">
                <p>Target Bulan Ini</p>
                <h3>75%</h3>
              </div>

              <div class="mock-card">
                <p>Pengeluaran Hari Ini</p>
                <h3>Rp 120.000</h3>
              </div>

            </div>

          </div>

          <!-- TEXT -->
          <div class="app-text">

            <span class="section-badge">
              TENTANG APLIKASI
            </span>

            <h2>
              Aplikasi Finansial Modern
            </h2>

            <p>
              Pil Time membantu pengguna mengelola pemasukan,
              pengeluaran, target tabungan, dan aktivitas harian
              dengan lebih mudah dan cerdas.
            </p>

            <p>
              Dengan dukungan AI, aplikasi ini mampu memberikan
              analisis pengeluaran, rekomendasi menabung,
              serta motivasi finansial secara personal.
            </p>

            <ul>
              <li>✔ Dashboard Keuangan Interaktif</li>
              <li>✔ AI Kategori Pengeluaran</li>
              <li>✔ Reminder Menabung</li>
              <li>✔ Target Finansial Pintar</li>
              <li>✔ Tampilan Modern dan Mudah Digunakan</li>
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

          <h2>
            Kenapa Harus Pil Time?
          </h2>

        </div>

        <div class="feature-grid">

          <div class="feature-card">
            <div class="icon">💡</div>

            <h3>Smart AI</h3>

            <p>
              AI membantu menganalisis pola keuangan pengguna
              secara otomatis.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">📊</div>

            <h3>Visual Statistik</h3>

            <p>
              Grafik interaktif memudahkan pengguna memahami
              kondisi keuangan mereka.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">🎯</div>

            <h3>Target Keuangan</h3>

            <p>
              Membantu mencapai tujuan finansial dengan sistem
              target yang terstruktur.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">🔔</div>

            <h3>Notifikasi Pintar</h3>

            <p>
              Pengingat otomatis agar pengguna tetap disiplin
              menabung dan mengatur pengeluaran.
            </p>
          </div>

        </div>

      </div>

    </section>

    <!-- CTA -->
    <section class="cta-section">

      <div class="container cta-content">

        <h2>
          Mulai Kelola Keuanganmu Sekarang
        </h2>

        <p>
          Unduh aplikasi Pil Time dan rasakan pengalaman
          finansial digital yang lebih cerdas, praktis,
          dan modern.
        </p>

        <a
          href="/apk/piltime.apk"
          download
          class="download-btn large"
        >
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
  background: #fff;
  color: #222;
}

/* HERO */
.hero{
  position: relative;
  min-height: 100vh;

  background: linear-gradient(135deg, #2563eb, #7c3aed);

  display: flex;
  align-items: center;
  justify-content: center;

  overflow: hidden;
  padding: 120px 20px;
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
}

.badge{
  display: inline-block;

  background: rgba(255,255,255,0.15);

  padding: 10px 18px;
  border-radius: 50px;

  margin-bottom: 25px;

  font-size: 14px;
  font-weight: 600;

  backdrop-filter: blur(10px);
}

.hero-content h1{
  font-size: 70px;
  margin-bottom: 20px;
  font-weight: 700;
}

.hero-content h1 span{
  color: #ffffff;
}

.hero-content p{
  font-size: 20px;
  line-height: 1.8;
  margin-bottom: 35px;
}

/* BUTTON */
.button-group{
  display: flex;
  justify-content: center;
  gap: 20px;
  flex-wrap: wrap;
}

.download-btn{
  background: white;
  color: #2563eb;

  padding: 16px 35px;

  border-radius: 50px;

  text-decoration: none;
  font-weight: 600;

  transition: 0.3s;

  display: inline-block;
}

.download-btn:hover{
  transform: translateY(-4px);
}

.secondary-btn{
  border: 2px solid white;
  color: white;

  padding: 16px 35px;

  border-radius: 50px;

  text-decoration: none;
  font-weight: 600;

  transition: 0.3s;
}

.secondary-btn:hover{
  background: white;
  color: #2563eb;
}

/* SECTION */
.section{
  padding: 100px 20px;
}

.bg-light{
  background: #f7f9fc;
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
  color: #2563eb;
  font-weight: 600;
}

.section-title h2{
  font-size: 42px;
  margin-top: 15px;
}

/* APP PREVIEW */
.app-preview{
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 50px;
  align-items: center;
}

/* PHONE */
.phone-mockup{
  width: 300px;
  height: 600px;

  background: #111;

  border-radius: 40px;

  padding: 15px;
  margin: auto;

  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
}

.screen{
  width: 100%;
  height: 100%;

  background: linear-gradient(180deg, #2563eb, #7c3aed);

  border-radius: 30px;

  padding: 30px 20px;

  color: white;
}

.screen h2{
  text-align: center;
  margin-bottom: 30px;
}

.mock-card{
  background: rgba(255,255,255,0.15);

  padding: 20px;

  border-radius: 20px;

  margin-bottom: 20px;

  backdrop-filter: blur(5px);
}

.mock-card h3{
  margin-top: 10px;
}

/* TEXT */
.section-badge{
  color: #2563eb;
  font-weight: 600;
  letter-spacing: 2px;
}

.app-text h2{
  font-size: 42px;
  margin: 20px 0;
}

.app-text p{
  line-height: 1.9;
  margin-bottom: 20px;
  color: #555;
}

.app-text ul{
  list-style: none;
  margin-top: 20px;
}

.app-text li{
  margin-bottom: 15px;
  font-size: 17px;
}

/* FEATURES */
.feature-grid{
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px,1fr));
  gap: 25px;
}

.feature-card{
  background: white;

  padding: 35px;

  border-radius: 24px;

  text-align: center;

  transition: 0.3s;

  box-shadow: 0 5px 20px rgba(0,0,0,0.05);
}

.feature-card:hover{
  transform: translateY(-5px);
}

.icon{
  font-size: 50px;
  margin-bottom: 20px;
}

.feature-card h3{
  margin-bottom: 15px;
  color: #2563eb;
}

.feature-card p{
  color: #555;
  line-height: 1.7;
}

/* CTA */
.cta-section{
  padding: 120px 20px;

  background: linear-gradient(135deg, #2563eb, #7c3aed);

  color: white;
  text-align: center;
}

.cta-content{
  max-width: 800px;
  margin: auto;
}

.cta-content h2{
  font-size: 45px;
  margin-bottom: 25px;
}

.cta-content p{
  font-size: 18px;
  line-height: 1.9;
  margin-bottom: 35px;
}

.large{
  font-size: 18px;
  padding: 18px 40px;
}

/* RESPONSIVE */
@media(max-width:768px){

  .hero-content h1{
    font-size: 45px;
  }

  .hero-content p{
    font-size: 17px;
  }

  .section-title h2,
  .app-text h2{
    font-size: 32px;
  }

  .phone-mockup{
    width: 260px;
    height: 520px;
  }

}
</style>
```
