<template>
  <div class="about-page">

    <div class="nav-links">
  <router-link to="/dashboard">Dashboard</router-link>
  <router-link to="/tentang">Tentang</router-link> <router-link to="/install">Install</router-link>
  <router-link to="/panduan">Panduan</router-link>
</div>
    <!-- NAVBAR -->
    <NavbarView />


    <!-- HERO SECTION -->
    <section class="hero">

      <div class="overlay"></div>

      <div class="hero-content">

        <span class="badge">
          🚀 Tentang Pil Time
        </span>

        <h1>Pil Time</h1>

        <p>
          Solusi cerdas untuk membantu generasi muda mengatur
          keuangan, waktu, dan kebiasaan menabung dengan bantuan teknologi AI.
        </p>

      </div>

    </section>

    <!-- LATAR BELAKANG -->
    <section class="section">

      <div class="container">

        <div class="section-title">
          <span>LATAR BELAKANG</span>
          <h2>Mengapa Pil Time Hadir?</h2>
        </div>

        <div class="content-box">

          <p>
            Pil Time hadir sebagai solusi atas permasalahan generasi muda
            yang sering mengalami kesulitan dalam mengatur keuangan,
            membangun kebiasaan menabung, dan mengelola waktu secara disiplin.
            Banyak orang memiliki pendapatan, namun tidak mengetahui
            ke mana uang mereka digunakan setiap harinya.
          </p>

          <p>
            Selain itu, perkembangan teknologi digital membuka peluang
            untuk menghadirkan sistem keuangan yang lebih cerdas,
            personal, dan interaktif. Oleh karena itu, Pil Time dikembangkan
            sebagai aplikasi modern berbasis AI yang membantu pengguna
            memahami pola pengeluaran, membangun target keuangan,
            serta meningkatkan produktivitas harian.
          </p>

        </div>

      </div>

    </section>

    <!-- FITUR -->
    <section class="section bg-light">

      <div class="container">

        <div class="section-title">
          <span>INOVASI PIL TIME</span>
          <h2>Fitur Unggulan</h2>
        </div>

        <div class="feature-grid">

          <div class="feature-card">
            <div class="icon">💰</div>

            <h3>Smart Financial Tracker</h3>

            <p>
              Memantau pemasukan, pengeluaran, tabungan,
              dan uang aktif secara real-time.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">🤖</div>

            <h3>AI Kategori Pengeluaran</h3>

            <p>
              Sistem AI secara otomatis mengkategorikan
              pengeluaran menjadi primer, sekunder, atau tersier.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">🎯</div>

            <h3>Target Tabungan Pintar</h3>

            <p>
              Membantu pengguna menentukan target menabung
              berdasarkan waktu dan kemampuan finansial.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">🔔</div>

            <h3>Reminder Menabung</h3>

            <p>
              Notifikasi otomatis untuk membantu pengguna
              tetap konsisten menabung setiap hari.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">📊</div>

            <h3>Dashboard Interaktif</h3>

            <p>
              Menampilkan grafik keuangan yang mudah dipahami
              dan membantu analisis pengeluaran pengguna.
            </p>
          </div>

          <div class="feature-card">
            <div class="icon">✨</div>

            <h3>Motivasi Finansial</h3>

            <p>
              Memberikan visual motivasi menabung dan pencapaian target
              agar pengguna tetap semangat mencapai tujuan finansial.
            </p>
          </div>

        </div>

      </div>

    </section>

    <!-- MANFAAT -->
    <section class="section">

      <div class="container">

        <div class="section-title">
          <span>MANFAAT</span>
          <h2>Manfaat Pil Time</h2>
        </div>

        <div class="benefit-grid">

          <div class="benefit-card">
            <div class="benefit-icon">✔</div>

            <p>
              Membantu masyarakat mengelola keuangan dengan lebih disiplin.
            </p>
          </div>

          <div class="benefit-card">
            <div class="benefit-icon">✔</div>

            <p>
              Meningkatkan kebiasaan menabung sejak usia muda.
            </p>
          </div>

          <div class="benefit-card">
            <div class="benefit-icon">✔</div>

            <p>
              Membantu pengguna memahami pola pengeluaran mereka.
            </p>
          </div>

          <div class="benefit-card">
            <div class="benefit-icon">✔</div>

            <p>
              Mendorong produktivitas dan pengelolaan waktu yang lebih baik.
            </p>
          </div>

          <div class="benefit-card">
            <div class="benefit-icon">✔</div>

            <p>
              Menghadirkan pengalaman finansial modern berbasis AI.
            </p>
          </div>

        </div>

      </div>

    </section>

    <!-- DEVELOPER -->
    <section class="section bg-light">

      <div class="container">

        <div class="section-title">
          <span>DEVELOPER</span>
          <h2>Pengembang Pil Time</h2>
        </div>

        <div class="developer-card">

          <div class="avatar">
            HS
          </div>

          <div>

            <h3>Hizkia Cristian Siahaan</h3>

            <p>
              Developer dan penggagas aplikasi Pil Time.
              Fokus pada pengembangan teknologi digital,
              AI, dan solusi inovatif untuk membantu masyarakat
              dalam pengelolaan keuangan serta produktivitas.
            </p>

          </div>

        </div>

      </div>

    </section>

    <!-- MITRA -->
    <section class="section">

      <div class="container">

        <div class="section-title">
          <span>MITRA</span>
          <h2>Partner Kolaborasi</h2>
        </div>

        <div class="partner-card">

          <div class="partner-logo">
            🏡
          </div>

          <div>

            <h3>Desa Nauli</h3>

            <p>
              Desa Nauli menjadi mitra dalam pengembangan dan implementasi
              Pil Time sebagai bagian dari dukungan terhadap transformasi
              digital dan peningkatan literasi keuangan masyarakat desa.
            </p>

          </div>

        </div>

      </div>

    </section>

  </div>
</template>

<script>
import NavbarView from './NavbarView.vue'

export default {
  name: "AboutPage",

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

.about-page{
  font-family: "Poppins", sans-serif;
  background: #ffffff;
  color: #1e293b;
}

/* HERO */
.hero{
  position: relative;
  min-height: 75vh;

  display: flex;
  align-items: center;
  justify-content: center;

  text-align: center;

  padding: 140px 20px 100px;

  background:
    radial-gradient(circle at top left,#dbeafe 0%,transparent 35%),
    radial-gradient(circle at bottom right,#ede9fe 0%,transparent 35%),
    linear-gradient(135deg,#2563eb,#7c3aed);

  overflow: hidden;
}

.overlay{
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,0.2);
}

.hero-content{
  position: relative;
  z-index: 2;
  max-width: 850px;
  color: white;
}

.badge{
  display: inline-block;

  background: rgba(255,255,255,0.15);

  padding: 10px 18px;
  border-radius: 50px;

  font-size: 14px;
  font-weight: 600;

  margin-bottom: 25px;

  backdrop-filter: blur(10px);
}

.hero-content h1{
  font-size: 72px;
  margin-bottom: 25px;
  font-weight: 800;
}

.hero-content p{
  font-size: 20px;
  line-height: 1.9;
}

/* SECTION */
.section{
  padding: 100px 8%;
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
  color: #2563eb;
  font-weight: 600;
  letter-spacing: 2px;
}

.section-title h2{
  font-size: 44px;
  margin-top: 15px;
}

.content-box{
  background: white;
  padding: 40px;
  border-radius: 30px;

  box-shadow: 0 10px 30px rgba(0,0,0,0.05);
}

.content-box p{
  line-height: 2;
  color: #64748b;
  margin-bottom: 20px;
  font-size: 17px;
}

/* FEATURES */
.feature-grid{
  display: grid;
  grid-template-columns: repeat(auto-fit,minmax(280px,1fr));
  gap: 25px;
}

.feature-card{
  background: white;

  padding: 35px;
  border-radius: 28px;

  transition: 0.3s;

  box-shadow: 0 10px 30px rgba(0,0,0,0.05);
}

.feature-card:hover{
  transform: translateY(-6px);
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
  color: #64748b;
  line-height: 1.8;
}

/* BENEFIT */
.benefit-grid{
  display: grid;
  grid-template-columns: repeat(auto-fit,minmax(260px,1fr));
  gap: 25px;
}

.benefit-card{
  background: #f8fafc;

  padding: 30px;
  border-radius: 24px;

  text-align: center;

  transition: 0.3s;
}

.benefit-card:hover{
  transform: translateY(-5px);
}

.benefit-icon{
  width: 60px;
  height: 60px;

  margin: auto auto 20px;

  border-radius: 20px;

  background: linear-gradient(135deg,#2563eb,#7c3aed);

  color: white;

  display: flex;
  align-items: center;
  justify-content: center;

  font-size: 24px;
  font-weight: bold;
}

.benefit-card p{
  color: #64748b;
  line-height: 1.8;
}

/* DEVELOPER */
.developer-card{
  background: white;

  padding: 40px;
  border-radius: 30px;

  display: flex;
  align-items: center;
  gap: 30px;

  box-shadow: 0 10px 30px rgba(0,0,0,0.05);
}

.avatar{
  width: 100px;
  height: 100px;

  border-radius: 50%;

  background: linear-gradient(135deg,#2563eb,#7c3aed);

  color: white;

  display: flex;
  align-items: center;
  justify-content: center;

  font-size: 32px;
  font-weight: bold;

  flex-shrink: 0;
}

.developer-card h3{
  margin-bottom: 15px;
}

.developer-card p{
  color: #64748b;
  line-height: 1.9;
}

/* PARTNER */
.partner-card{
  background: #f8fafc;

  padding: 40px;
  border-radius: 30px;

  display: flex;
  align-items: center;
  gap: 30px;
}

.partner-logo{
  width: 100px;
  height: 100px;

  border-radius: 30px;

  background: linear-gradient(135deg,#2563eb,#7c3aed);

  color: white;

  display: flex;
  align-items: center;
  justify-content: center;

  font-size: 42px;

  flex-shrink: 0;
}

.partner-card h3{
  margin-bottom: 15px;
}

.partner-card p{
  color: #64748b;
  line-height: 1.9;
}

/* RESPONSIVE */
@media(max-width:768px){

  .hero-content h1{
    font-size: 48px;
  }

  .hero-content p{
    font-size: 17px;
  }

  .section-title h2{
    font-size: 34px;
  }

  .developer-card,
  .partner-card{
    flex-direction: column;
    text-align: center;
  }

}

</style>