import { createRouter, createWebHistory } from 'vue-router';
import RegisterPage from '../components/RegisterPage.vue';
import HomePage from '../components/HomePage.vue';

const routes = [
  { path: '/', name: 'Register', component: RegisterPage },
  { path: '/home', name: 'Home', component: HomePage },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;