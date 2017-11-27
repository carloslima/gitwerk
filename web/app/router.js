import EmberRouter from '@ember/routing/router';
import config from './config/environment';

const Router = EmberRouter.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('auth', function() {
    this.route('login');
    this.route('register');
  });
  this.route('settings');
  this.route('repository', { path: '/:namespace/:name'}, function() {
    this.route('index', { path: '/' });
    this.route('tree', { path: '/tree/:tree_id'}, function() { });
    this.route('tree', { path: '/tree/:tree_id/*tree_path'}, function() { });
  });
});

export default Router;
