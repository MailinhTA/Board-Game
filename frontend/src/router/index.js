import Vue from 'vue'
import Router from 'vue-router'
import HelloWorld from '@/components/HelloWorld'
import GamesModule from '@/components/GamesModule'

import ProfileModule from '@/components/ProfileModule.vue'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'HelloWorld',
      component: HelloWorld
    },
    
    // Games Module Routes
    {
      path: '/games',
      redirect: '/games/list/all' // Redirect to the games list
    },
    {
      path: '/games/:action/:id',
      name: 'games',
      component: GamesModule,
      props: true
    },

    // Auth Module Routes
    {
      path: '/profile/:action',
      name: 'profile',
      component: ProfileModule,
      props: true
    },
  ]
})
