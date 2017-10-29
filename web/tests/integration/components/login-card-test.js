import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('login-card', 'Integration | Component | login card', {
  integration: true
});

test('it renders', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });

  // Template block usage:
  this.render(hbs`{{login-card}}`);

  assert.equal(this.$().text().trim().replace(/[\s\n]+/g, ''),
    'LogintoGitWerkUsernamePassword');
});
