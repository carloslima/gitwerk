import Component from '@ember/component';

export default Component.extend({
  init() {
    this._super(...arguments);
    if (this.get('_parentComponent') &&
        this.get('_parentComponent')._setupChildComponent) {
      this.get('_parentComponent')._setupChildComponent(this);
    }
  }
});
