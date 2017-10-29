import { moduleFor, test } from 'ember-qunit';

moduleFor('route:auth/login', 'Unit | Route | auth/login', {
  needs: ['service:session', 'service:flashMessages']
});

test('it exists', function(assert) {
  let route = this.subject();
  assert.ok(route);
});
