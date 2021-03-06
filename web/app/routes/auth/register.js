import Route from '@ember/routing/route';

export default Route.extend({
  actions: {
    doRegister() {
      this.get('currentModel').save()
      .then(() => {
        this.transitionTo('auth.login');
      }).catch((resp) => {
        const { errors } = resp;
        this.get('flashMessages').danger(errors.mapBy('detail').join(', '));
      });
    }
  },
  model() {
    return this.store.createRecord('user');
  }
});
