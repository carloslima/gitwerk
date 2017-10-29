import { moduleFor, test } from 'ember-qunit';

moduleFor('route:settings', 'Unit | Route | settings', {
  needs: ['service:session']
});

test('it exists', function(assert) {
  let route = this.subject();
  assert.ok(route);
});
