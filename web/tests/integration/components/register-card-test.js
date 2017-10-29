import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('register-card', 'Integration | Component | register card', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  // Template block usage:
  this.render(hbs`{{register-card}}`);

   assert.equal(this.$().text().trim().replace(/[\s\n]+/g, ''),
    'RegisterwithGitWerkUsernameEmailPasswordConfirmPassword');
});
