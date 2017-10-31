export function initialize(/* application */) {
  // application.inject('route', 'foo', 'service:foo');
  if (window && window.validate_field) {
      window.validate_field = function() {};
  }
}

export default {
  name: 'materialize-setup',
  initialize
};
