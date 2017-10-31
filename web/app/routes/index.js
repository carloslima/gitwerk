import Ember from 'ember';
import config from '../config/environment';
import fetch from 'ember-network/fetch';
import GitWerkRoute from './basic';



const { inject } = Ember;

export default GitWerkRoute.extend({
  session: inject.service(),
  beforeModel() {
    if(!this.get('session').get('isAuthenticated')) {
      this.transitionTo('auth.login');
    }
  },
  afterModel() {
    return fetch(`${config.APP.host}/${config.APP.namespace}/sessions/current`, {
      type: 'GET',
      headers: {
        'Authorization': `Bearer ${this.get('session').get('session.content.authenticated.access_token')}`
      }
    }).then((raw) => {
      return raw.json().then((data) => {
        const currentUser = this.store.push(data);
        this.set('session.currentUser', currentUser);
      });
    });
  }
});
