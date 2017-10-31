import userValidations from 'gitwerk-web/utils/user-validations';
import { module, test } from 'qunit';

module('Unit | Utility | user validations');

// Replace this with your real tests.
test('it works', function(assert) {
  assert.ok(userValidations.email);
  assert.ok(userValidations.password);
  assert.ok(userValidations.passwordConfirmation);
});
