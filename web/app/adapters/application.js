import DS from 'ember-data';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';
import config from '../config/environment';

export default DS.JSONAPIAdapter.extend(DataAdapterMixin, {
  host: config.APP.host,
  namespace: config.APP.namespace,
  authorizer: 'authorizer:oauth2',

  urlForCreateRecord(modelName/*, snapshot*/) {
    switch(modelName) {
      /*case 'user':
      case 'users':
        return this._super.apply(this, arguments).replace('users', 'register');
        */
      default:
        return this._super(...arguments);
    }
  }
});
