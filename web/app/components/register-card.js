import Component from '@ember/component';
import { username, email, password, passwordConfirmation } from '../utils/user-validations';
import { buildValidations } from 'ember-cp-validations';

const Validations = buildValidations({
  'model.username': username,
  'model.email': email,
  'model.password': password,
  'model.passwordConfirmation': passwordConfirmation
});

export default Component.extend(Validations, {

});
