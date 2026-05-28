```vue
<template>

  <div class="landing-page">

    <!-- NAVBAR -->
    <NavbarView />

    <!-- HERO SECTION -->
    <section class="hero">

      <div class="hero-left">

        <span class="badge">
          🚀 Smart Financial AI App
        </span>

        <h1>
          Kelola Keuangan &
          Waktu Lebih Cerdas
          Bersama <span>Pil Time</span>
        </h1>

        <p>
          Pil Time membantu pengguna mengatur keuangan,
          membangun kebiasaan menabung, dan meningkatkan
          produktivitas dengan bantuan teknologi AI modern.
        </p>

        <div class="hero-buttons">

          <router-link to="/install" class="btn-primary">
            📥 Download APK
          </router-link>

          <router-link to="/tentang" class="btn-secondary">
            Tentang Pil Time
          </router-link>

        </div>

        <!-- STATS -->
        <div class="stats">

          <div class="stat-card">
            <h2>10K+</h2>
            <p>Pengguna</p>
          </div>

          <div class="stat-card">
            <h2>95%</h2>
            <p>Produktivitas</p>
          </div>

          <div class="stat-card">
            <h2>24/7</h2>
            <p>AI Support</p>
          </div>

        </div>

      </div>

      <!-- PHONE MOCKUP -->
      <div class="hero-right">

        <div class="phone">

          <div class="screen">

            <div class="top-card">
              <p>Total Tabungan</p>
              <h2>Rp 5.250.000</h2>
            </div>

            <div class="mini-grid">

              <div class="mini-card">
                <span>💰</span>
                <h3>Income</h3>
                <p>+ Rp 2.5JT</p>
              </div>

              <div class="mini-card">
                <span>📉</span>
                <h3>Expense</h3>
                <p>- Rp 750K</p>
              </div>

            </div>

            <div class="chart-card">
              <p>Progress Target</p>

              <div class="progress-bar">
                <div class="progress"></div>
              </div>

              <span>78% Tercapai</span>
            </div>

          </div>

        </div>

      </div>

    </section>

    <!-- FEATURES -->
    <section class="features">

      <div class="section-title">
        <span>FITUR UNGGULAN</span>
        <h2>Kenapa Harus Pil Time?</h2>
      </div>

      <div class="feature-grid">

        <div class="feature-card">
          <div class="icon">🤖</div>
          <h3>AI Smart Analysis</h3>
          <p>
            AI menganalisis pengeluaran dan membantu
            pengguna mengatur finansial lebih efisien.
          </p>
        </div>

        <div class="feature-card">
          <div class="icon">📊</div>
          <h3>Dashboard Interaktif</h3>
          <p>
            Statistik dan grafik modern untuk memahami
            kondisi keuangan dengan mudah.
          </p>
        </div>

        <div class="feature-card">
          <div class="icon">🎯</div>
          <h3>Target Finansial</h3>
          <p>
            Buat target menabung dengan rekomendasi
            AI sesuai kemampuan pengguna.
          </p>
        </div>

        <div class="feature-card">
          <div class="icon">🔔</div>
          <h3>Reminder Pintar</h3>
          <p>
            Pengingat otomatis agar pengguna tetap
            disiplin menabung setiap hari.
          </p>
        </div>

      </div>

    </section>

    <!-- CTA -->
    <section class="cta">

      <h2>
        Mulai Perjalanan Finansialmu Hari Ini
      </h2>

      <p>
        Download aplikasi Pil Time sekarang dan
        nikmati pengalaman finansial modern berbasis AI.
      </p>

      <router-link to="/install" class="cta-btn">
        🚀 Download Sekarang
      </router-link>

    </section>

  </div>

</template>

<script>

import NavbarView from './NavbarView.vue'

export default {
  name: "LandingView",

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

.landing-page{
  font-family: "Poppins", sans-serif;
  background: #ffffff;
  color: #1e293b;
}

/* HERO */
.hero{
  min-height: 100vh;
  display: grid;
  grid-template-columns: repeat(auto-fit,minmax(350px,1fr));
  align-items: center;
  padding: 140px 8% 100px;
  gap: 60px;

  background:
    radial-gradient(circle at top left,#dbeafe 0%,transparent 40%),
    radial-gradient(circle at bottom right,#ede9fe 0%,transparent 40%),
    #ffffff;
}

.badge{
  background: #dbeafe;
  color: #2563eb;
  padding: 10px 18px;
  border-radius: 50px;
  font-size: 14px;
  font-weight: 600;
  display: inline-block;
  margin-bottom: 25px;
}

.hero-left h1{
  font-size: 64px;
  line-height: 1.2;
  margin-bottom: 25px;
  font-weight: 800;
}

.hero-left h1 span{
  background: linear-gradient(135deg,#2563eb,#7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-left p{
  font-size: 18px;
  line-height: 1.9;
  color: #64748b;
  margin-bottom: 35px;
}

/* BUTTONS */
.hero-buttons{
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  margin-bottom: 50px;
}

.btn-primary{
  background: linear-gradient(135deg,#2563eb,#7c3aed);
  color: white;
  text-decoration: none;
  padding: 16px 34px;
  border-radius: 50px;
  font-weight: 600;
  transition: 0.3s;
}

.btn-primary:hover{
  transform: translateY(-4px);
}

.btn-secondary{
  border: 2px solid #cbd5e1;
  color: #334155;
  text-decoration: none;
  padding: 16px 34px;
  border-radius: 50px;
  font-weight: 600;
  transition: 0.3s;
}

.btn-secondary:hover{
  border-color: #2563eb;
  color: #2563eb;
}

/* STATS */
.stats{
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.stat-card{
  background: white;
  padding: 25px;
  border-radius: 24px;
  min-width: 140px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.05);
}

.stat-card h2{
  font-size: 28px;
  color: #2563eb;
  margin-bottom: 10px;
}

/* PHONE */
.hero-right{
  display: flex;
  justify-content: center;
}

.phone{
  width: 320px;
  height: 650px;
  background: #111827;
  border-radius: 45px;
  padding: 15px;
  box-shadow: 0 30px 60px rgba(0,0,0,0.15);
}

.screen{
  width: 100%;
  height: 100%;
  border-radius: 35px;
  padding: 30px 20px;
  background: linear-gradient(180deg,#2563eb,#7c3aed);
  color: white;
}

.top-card,
.mini-card,
.chart-card{
  background: rgba(255,255,255,0.15);
  backdrop-filter: blur(8px);
}

.top-card{
  padding: 25px;
  border-radius: 24px;
  margin-bottom: 25px;
}

.mini-grid{
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 25px;
}

.mini-card{
  padding: 18px;
  border-radius: 20px;
}

.chart-card{
  padding: 25px;
  border-radius: 24px;
}

.progress-bar{
  width: 100%;
  height: 12px;
  background: rgba(255,255,255,0.2);
  border-radius: 20px;
  margin: 20px 0;
  overflow: hidden;
}

.progress{
  width: 78%;
  height: 100%;
  background: white;
}

/* FEATURES */
.features{
  padding: 100px 8%;
  background: #f8fafc;
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

.feature-grid{
  display: grid;
  grid-template-columns: repeat(auto-fit,minmax(260px,1fr));
  gap: 25px;
}

.feature-card{
  background: white;
  padding: 35px;
  border-radius: 28px;
  transition: 0.3s;
  box-shadow: 0 10px 30px rgba(0,0,0,0.04);
}

.feature-card:hover{
  transform: translateY(-6px);
}

.icon{
  font-size: 50px;
  margin-bottom: 20px;
}

/* CTA */
.cta{
  padding: 120px 8%;
  text-align: center;
  background: linear-gradient(135deg,#2563eb,#7c3aed);
  color: white;
}

.cta h2{
  font-size: 50px;
  margin-bottom: 25px;
}

.cta p{
  max-width: 700px;
  margin: auto;
  line-height: 1.9;
  margin-bottom: 40px;
}

.cta-btn{
  background: white;
  color: #2563eb;
  text-decoration: none;
  padding: 18px 40px;
  border-radius: 50px;
  font-weight: 700;
  display: inline-block;
}

@media(max-width:768px){

  .hero-left h1{
    font-size: 42px;
  }

  .section-title h2,
  .cta h2{
    font-size: 34px;
  }

  .phone{
    width: 280px;
    height: 580px;
  }

}
</style>
```
