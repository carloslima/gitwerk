import Component from '@ember/component';
import { username,  password } from '../utils/user-validations';
import { buildValidations } from 'ember-cp-validations';


const Validations = buildValidations({
  'model.username': username,
  'model.password': password
});

export default Component.extend(Validations, {

});
