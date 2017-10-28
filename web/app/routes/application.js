import Route from '@ember/routing/route';


export default Route.extend({
  actions: {
    logout() {
      this.get('session').invalidate();
    }
  }
});
