<template>
  <nav class="navbar">
    
    <!-- LOGO -->
    <div class="logo-section">
      <div
    class="logo-icon"
    style="
      width: 60px;
      height: 60px;
      border-radius: 50%;
      overflow: hidden;
      border: 3px solid white;
      box-shadow: 0 4px 10px rgba(0,0,0,0.2);
      background: white;
      display: flex;
      justify-content: center;
      align-items: center;
    "
  >
    <img
      src="./../../assets/images/logo.jpeg"
      alt="Logo"
      style="
        width: 100%;
        height: 100%;
        object-fit: cover;
      "
    />
  </div>

      <h1 class="logo-text">
        Pil Time
      </h1>
    </div>

    <!-- MENU -->
    <ul class="nav-links">

      <li>
        <a href="/">
          Dashboard
        </a>
      </li>

      <li>
        <a href="/tentang">
          Tentang
        </a>
      </li>

      <li>
        <a href="/install">
          Install
        </a>
      </li>

      <li>
        <a href="/panduan">
          Panduan
        </a>
      </li>

      <li>
        <a href="/login" class="login-btn">
          Login
        </a>
      </li>

    </ul>

    <!-- MOBILE MENU -->
    <div class="menu-toggle" @click="toggleMenu">
      ☰
    </div>

    <!-- MOBILE NAV -->
    <div class="mobile-menu" :class="{ active: isOpen }">

      <a href="/">Dashboard</a>
      <a href="/tentang">Tentang</a>
      <a href="/install">Install</a>
      <a href="/panduan">Panduan</a>

      <a href="/login" class="mobile-login">
        Login
      </a>

    </div>

  </nav>
</template>

<script>
export default {
  name: "Navbar",

  data() {
    return {
      isOpen: false,
    };
  },

  methods: {
    toggleMenu() {
      this.isOpen = !this.isOpen;
    },
  },
};
</script>

<style scoped>

/* RESET */
*{
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* NAVBAR */
.navbar{
  width: 100%;
  height: 85px;
  background: rgba(255,255,255,0.9);
  backdrop-filter: blur(10px);

  display: flex;
  align-items: center;
  justify-content: space-between;

  padding: 0 8%;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 999;

  border-bottom: 1px solid rgba(0,0,0,0.05);
}

/* LOGO */
.logo-section{
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon{
  width: 45px;
  height: 45px;

  border-radius: 14px;

  background: linear-gradient(135deg, #2563eb, #7c3aed);

  display: flex;
  align-items: center;
  justify-content: center;

  color: white;
  font-size: 22px;

  box-shadow: 0 5px 15px rgba(37,99,235,0.3);
}

.logo-text{
  font-size: 28px;
  font-weight: 700;
  color: #1e293b;
  font-family: "Poppins", sans-serif;
}

/* MENU */
.nav-links{
  display: flex;
  align-items: center;
  gap: 35px;
  list-style: none;
}

.nav-links a{
  text-decoration: none;
  color: #334155;
  font-weight: 500;
  font-size: 16px;
  transition: 0.3s;
  position: relative;
}

.nav-links a:hover{
  color: #2563eb;
}

/* UNDERLINE EFFECT */
.nav-links a::after{
  content: "";
  position: absolute;
  left: 0;
  bottom: -6px;

  width: 0%;
  height: 2px;

  background: #2563eb;
  transition: 0.3s;
}

.nav-links a:hover::after{
  width: 100%;
}

/* LOGIN BUTTON */
.login-btn{
  background: linear-gradient(135deg, #2563eb, #7c3aed);
  color: white !important;

  padding: 12px 28px;
  border-radius: 50px;

  transition: 0.3s;
}

.login-btn:hover{
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(37,99,235,0.25);
}

.login-btn::after{
  display: none;
}

/* MOBILE MENU */
.menu-toggle{
  display: none;
  font-size: 30px;
  cursor: pointer;
  color: #1e293b;
}

/* MOBILE NAV */
.mobile-menu{
  position: absolute;
  top: 85px;
  left: 0;

  width: 100%;
  background: white;

  display: flex;
  flex-direction: column;

  padding: 20px;

  gap: 20px;

  transform: translateY(-200%);
  transition: 0.4s;

  box-shadow: 0 10px 25px rgba(0,0,0,0.08);
}

.mobile-menu a{
  text-decoration: none;
  color: #334155;
  font-size: 17px;
  font-weight: 500;
}

.mobile-menu.active{
  transform: translateY(0%);
}

.mobile-login{
  background: linear-gradient(135deg, #2563eb, #7c3aed);
  color: white !important;

  text-align: center;

  padding: 14px;
  border-radius: 15px;
}

/* RESPONSIVE */
@media(max-width: 900px){

  .nav-links{
    display: none;
  }

  .menu-toggle{
    display: block;
  }

}

</style>