class Article < ActiveRecord::Base
  belongs_to :tracker
end


# TODO: Un flux contient plusieurs articles. Et un article peut exister dans plusieurs flux.
#       Pour l'instant on a seulement un champ rssfeed_id dans la table article, ce qui associe un article
#       à un flux (et permet donc d'avoir plusieurs articles pour un flux). Mais cette solution ne permet
#       pas d'associer un article à plusieurs flux. Il faudrait donc utiliser une table de liaison entre la
#       table article et la table rssfeed. Cette table contiendrait les champs rssfeed_id et article_id, et
#       permettrait d'associer plusieurs articles à un flux, et plusieurs flux à un article.
#       La condition rails 'has_many:through' peut optionnellement être utilisée pour faciliter les opérations.
#       Cette table doit être remplie à la création des articles (méthode fetch_feed_worker)