import Repo from 'gitwerk-web/models/repository';
import GitWerkRoute from 'gitwerk-web/routes/basic';


export default GitWerkRoute.extend({
  model(params) {
    const {name, owner} = params;
    const slug = `${owner}/${name}`;
    return Repo.fetchBySlug(this.get('store'), slug);
  },
});
