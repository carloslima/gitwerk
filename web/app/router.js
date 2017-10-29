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
  this.route('repo', { path: '/:owner/:name'}, function() {
    this.route('index', { path: '/' });
  });
});

export default Router;
