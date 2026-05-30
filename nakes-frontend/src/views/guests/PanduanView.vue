<template>
  <div class="panduan-page">

    <!-- NAVBAR -->
    <NavbarView />

    <!-- HERO -->
    <section class="hero">

      <div class="hero-content">

        <span class="badge">
          📘 Panduan Penggunaan
        </span>

        <h1>
          Pelajari Cara Menggunakan
          <span>Pil Time</span>
        </h1>

        <p>
          Ikuti video tutorial dan dokumentasi penggunaan
          untuk memahami seluruh fitur Pil Time dengan mudah.
        </p>

      </div>

    </section>

    <!-- VIDEO TUTORIAL -->
    <section class="tutorial-section">

      <div class="section-title">
        <span>VIDEO TUTORIAL</span>
        <h2>Dokumentasi Penggunaan Aplikasi</h2>
      </div>

      <div class="video-container">

        <!-- YOUTUBE EMBED -->
        <iframe
          width="100%"
          height="500"
          src="https://www.youtube.com/embed/dQw4w9WgXcQ"
          title="Pil Time Tutorial"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
        </iframe>

      </div>

      <!-- STEP CARDS -->
      <div class="tutorial-description">

        <div class="tutorial-card">
          <span>1</span>

          <div>
            <h3>Login ke Aplikasi</h3>

            <p>
              Pengguna dapat login menggunakan akun
              yang telah terdaftar pada sistem Pil Time.
            </p>
          </div>
        </div>

        <div class="tutorial-card">
          <span>2</span>

          <div>
            <h3>Kelola Keuangan</h3>

            <p>
              Tambahkan pemasukan, pengeluaran,
              dan target tabungan dengan mudah.
            </p>
          </div>
        </div>

        <div class="tutorial-card">
          <span>3</span>

          <div>
            <h3>Gunakan AI Analysis</h3>

            <p>
              Sistem AI akan membantu pengguna
              menganalisis pola pengeluaran otomatis.
            </p>
          </div>
        </div>

        <div class="tutorial-card">
          <span>4</span>

          <div>
            <h3>Monitoring Progress</h3>

            <p>
              Pantau perkembangan target finansial
              melalui dashboard interaktif Pil Time.
            </p>
          </div>
        </div>

      </div>

    </section>

<!-- PDF SECTION -->
<section class="pdf-section">

  <div class="section-title">
    <span>DOKUMENTASI PDF</span>
    <h2>Panduan Penggunaan Aplikasi</h2>
  </div>

  <!-- PANDUAN NAKES -->
  <div class="pdf-box">

    <h3 class="pdf-title">
      👨‍⚕️ Panduan Tenaga Kesehatan
    </h3>

    <div class="pdf-container">

      <iframe
        :src="panduanNakes"
        width="100%"
        height="800px"
        class="pdf-viewer">
      </iframe>

    </div>

    <div class="download-box">

      <a
        :href="panduanNakes"
        download
        class="download-btn"
      >
        📥 Download Panduan Nakes
      </a>

    </div>

  </div>

  <!-- PANDUAN PASIEN -->
  <div class="pdf-box">

    <h3 class="pdf-title">
      🧑‍🤝‍🧑 Panduan Pasien
    </h3>

    <div class="pdf-container">

      <iframe
        :src="panduanPasien"
        width="100%"
        height="800px"
        class="pdf-viewer">
      </iframe>

    </div>

    <div class="download-box">

      <a
        :href="panduanPasien"
        download
        class="download-btn"
      >
        📥 Download Panduan Pasien
      </a>

    </div>

  </div>

</section>

  </div>
</template>

<script>
import NavbarView from './NavbarView.vue'

// IMPORT PDF
import panduanNakes from './../../assets/pdf/panduannakes.pdf'
import panduanPasien from './../../assets/pdf/panduanpasien.pdf'

export default {
  name: "PanduanView",

  components: {
    NavbarView
  },

  data() {
    return {
      panduanNakes,
      panduanPasien
    }
  }
}
</script>

<style scoped>

*{
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

.panduan-page{
  font-family: "Poppins", sans-serif;
  background: #ffffff;
  color: #1e293b;
}

/* HERO */
.hero{
  min-height: 70vh;

  display: flex;
  align-items: center;
  justify-content: center;

  text-align: center;

  padding: 140px 20px 100px;

  background:
    radial-gradient(circle at top left,#dbeafe 0%,transparent 35%),
    radial-gradient(circle at bottom right,#ede9fe 0%,transparent 35%),
    #ffffff;
}

.hero-content{
  max-width: 850px;
}

.badge{
  display: inline-block;

  background: #dbeafe;
  color: #2563eb;

  padding: 10px 18px;
  border-radius: 50px;

  font-size: 14px;
  font-weight: 600;

  margin-bottom: 25px;
}

.hero-content h1{
  font-size: 60px;
  line-height: 1.2;
  margin-bottom: 25px;
  font-weight: 800;
}

.hero-content h1 span{
  background: linear-gradient(135deg,#2563eb,#7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-content p{
  font-size: 18px;
  line-height: 1.9;
  color: #64748b;
}

/* SECTION */
.tutorial-section,
.pdf-section{
  padding: 100px 8%;
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
  font-size: 42px;
  margin-top: 15px;
}

/* VIDEO */
.video-container{
  overflow: hidden;
  border-radius: 30px;

  box-shadow: 0 20px 50px rgba(0,0,0,0.08);

  margin-bottom: 60px;
}

/* STEP CARDS */
.tutorial-description{
  display: grid;
  grid-template-columns: repeat(auto-fit,minmax(280px,1fr));
  gap: 25px;
}

.tutorial-card{
  background: #f8fafc;

  padding: 30px;
  border-radius: 24px;

  display: flex;
  gap: 20px;

  transition: 0.3s;

  box-shadow: 0 10px 25px rgba(0,0,0,0.04);
}

.tutorial-card:hover{
  transform: translateY(-5px);
}

.tutorial-card span{
  min-width: 55px;
  height: 55px;

  border-radius: 18px;

  background: linear-gradient(135deg,#2563eb,#7c3aed);

  color: white;

  display: flex;
  align-items: center;
  justify-content: center;

  font-weight: 700;
  font-size: 20px;
}

.tutorial-card h3{
  margin-bottom: 10px;
}

.tutorial-card p{
  color: #64748b;
  line-height: 1.8;
}

/* PDF */
.pdf-section{
  background: #f8fafc;
}

.pdf-container{
  overflow: hidden;

  border-radius: 30px;

  background: white;

  padding: 20px;

  box-shadow: 0 20px 50px rgba(0,0,0,0.06);
}

.pdf-box{
  margin-bottom: 80px;
}

.pdf-title{
  font-size: 28px;
  margin-bottom: 25px;
  color: #1e293b;
}

.pdf-viewer{
  border: none;
  border-radius: 20px;
}

/* DOWNLOAD BUTTON */
.download-box{
  margin-top: 40px;
  text-align: center;
}

.download-btn{
  display: inline-block;

  background: linear-gradient(135deg,#2563eb,#7c3aed);
  color: white;

  text-decoration: none;

  padding: 18px 36px;
  border-radius: 50px;

  font-weight: 600;

  transition: 0.3s;
}

.download-btn:hover{
  transform: translateY(-4px);
  box-shadow: 0 10px 25px rgba(37,99,235,0.25);
}

/* RESPONSIVE */
@media(max-width:768px){

  .hero-content h1{
    font-size: 40px;
  }

  .section-title h2{
    font-size: 32px;
  }

  iframe{
    height: 250px;
  }

}

</style>