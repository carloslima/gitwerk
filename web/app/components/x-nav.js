import Component from '@ember/component';

export default Component.extend({
  classNames: ['navbar-fixed', 'x-nav'],
  didInsertElement() {
    this._super(...arguments);

    // Add the ID of our side-nav UL as the data-activates
    //  property of the collapse button
    this.$('a.button-collapse')
      .attr('data-activates', this.get('_sideNavId'));

    // Initialize the sideNav
    this.$(".button-collapse").sideNav({
      closeOnClick: true
    });

    // Initialize all dropdowns menus within the menu
    this.$(".dropdown-button").dropdown();
  },
  _setupChildComponent(childComponent) {
    if (childComponent.classNames.includes('side-nav')) {
      this.set('_sideNavId', childComponent.elementId);
    }
  }});
