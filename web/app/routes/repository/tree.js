import Route from '@ember/routing/route';

import TreeEntry from 'gitwerk-web/models/tree-entry';


export default Route.extend({
  model(params) {
    return this._super(...arguments);
  },
  setupController() {
    console.log(this.controllerFor('repository').set('isRepoHomePage', false));
    return this._super(...arguments);
  },
  deactivate() {
    console.log(this.controllerFor('repository').set('isRepoHomePage', true));
  }
});
