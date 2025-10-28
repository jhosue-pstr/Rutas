from .bus import Bus, BusCreate, BusPublic, BusUpdate
from .chofer import Chofer, ChoferCreate, ChoferPublic, ChoferUpdate
from .punto_ruta import PuntoRuta, PuntoRutaCreate, PuntoRutaPublic, PuntoRutaUpdate
from .ruta import Ruta, RutaCreate, RutaPublic, RutaUpdate
from .paradero import Paradero, ParaderoCreate, ParaderoPublic, ParaderoUpdate
from .lugar_cercano import LugarCercano, LugarCercanoCreate, LugarCercanoPublic, LugarCercanoUpdate
from .bus_favorito import BusFavorito, BusFavoritoCreate, BusFavoritoPublic, BusFavoritoUpdate
from .noticia import Noticia,NoticiaBase,NoticiaCreate,NoticiaPublic,NoticiaUpdate
from .lugar_favorito import LugarFavorito,LugarFavoritoBase,LugarFavoritoCreate,LugarFavoritoPublic,LugarFavoritoUpdate

# Rebuild para resolver forward references
BusPublic.model_rebuild()
ChoferPublic.model_rebuild()
PuntoRutaPublic.model_rebuild()
RutaPublic.model_rebuild()
ParaderoPublic.model_rebuild()
LugarCercanoPublic.model_rebuild()
BusFavoritoPublic.model_rebuild()
NoticiaPublic.model_rebuild()
LugarFavoritoPublic.model_rebuild()
