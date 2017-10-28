import Route from '@ember/routing/route';

export default Route.extend({
  actions: {
    doRegister() {
      this.get('currentModel').save()
      .then(() => {
        this.transitionTo('auth.login');
      })
    }
  },
  model() {
    return this.store.createRecord('user');
  }
});
