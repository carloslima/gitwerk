import Repo from 'gitwerk-web/models/repository';
import GitWerkRoute from 'gitwerk-web/routes/basic';


export default GitWerkRoute.extend({
  model(params) {
    const {name, namespace} = params;
    const slug = `${namespace}/${name}`;
    //return Repo.fetchBySlug(this.get('store'), slug);
    return this.get('store').findRecord('repository', slug);
  },
});
