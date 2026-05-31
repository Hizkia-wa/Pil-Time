<template>
  <footer class="guest-footer">
    <div class="footer-inner">
      <div class="footer-brand">
        <h2>Pil Time</h2>
        <p>Membantu pasien dan tenaga kesehatan tetap disiplin dalam pengobatan setiap hari.</p>
      </div>

      <div class="footer-links">
        <router-link to="/">Dashboard</router-link>
        <router-link to="/tentang">Tentang</router-link>
        <router-link to="/install">Install</router-link>
        <router-link to="/panduan">Panduan</router-link>
      </div>
    </div>

    <div class="footer-bottom">
      <p>© 2026 Pil Time. Semua hak dilindungi.</p>
      <p>Didukung oleh Pil Time untuk kesehatan yang lebih teratur.</p>
    </div>
  </footer>
</template>

<script>
export default {
  name: "FooterView",
}
</script>

<style scoped>
.guest-footer {
  padding: 40px 8%;
  background: #0f172a;
  color: #f8fafc;
  margin-top: 60px;
}

.footer-inner {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 32px;
  flex-wrap: wrap;
}

.footer-brand h2 {
  font-size: 26px;
  margin-bottom: 12px;
}

.footer-brand p {
  max-width: 520px;
  color: #cbd5e1;
  line-height: 1.8;
}

.footer-links {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.footer-links a {
  color: #94a3b8;
  text-decoration: none;
  font-weight: 600;
  transition: color 0.2s ease;
}

.footer-links a:hover {
  color: #f8fafc;
}

.footer-bottom {
  margin-top: 32px;
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  justify-content: space-between;
  border-top: 1px solid rgba(248,250,252,0.12);
  padding-top: 24px;
  color: #94a3b8;
  font-size: 14px;
}

@media (max-width: 768px) {
  .footer-inner {
    flex-direction: column;
  }

  .footer-bottom {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
