
     
import { createRouter, createWebHistory } from 'vue-router';
import RegisterPage from '../components/RegisterPage.vue';
import HomePage from '../components/HomePage.vue';
import AutomatonPage from '@/views/AutomatonPage.vue';

const routes = [
  { path: '/', name: 'Register', component: RegisterPage },
  { path: '/home', name: 'Home', component: HomePage },
  { path: '/Model/:projectName/:projectDescription',
    name: 'AutoPage',
    component: AutomatonPage,
    props: true,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;