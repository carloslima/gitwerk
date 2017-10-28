import Ember from 'ember';

const { Route, inject } = Ember;

export default Route.extend({
  session: inject.service(),
  flashMessages: inject.service(),
  actions: {
    doLogin() {
      const user = this.get('currentModel');
      this.get('session')
      .authenticate(
        'authenticator:gitwerk', user.username, user.password
      ).then(() => {
        this.get('flashMessages').success('Logged in!');
      }).catch((response) => {
        this.get('flashMessages')
        .danger('There was a problem with your username or password, please try again');
      })
      ;
    }
  },
  model() {
    return {
      username: '',
      password: ''
    };
  }
});
