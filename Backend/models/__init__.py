from .bus import Bus, BusCreate, BusPublic, BusUpdate
from .chofer import Chofer, ChoferCreate, ChoferPublic, ChoferUpdate
from .punto_ruta import PuntoRuta, PuntoRutaCreate, PuntoRutaPublic, PuntoRutaUpdate
from .ruta import Ruta, RutaCreate, RutaPublic, RutaUpdate

# Rebuild para resolver forward references
BusPublic.model_rebuild()
ChoferPublic.model_rebuild()
PuntoRutaPublic.model_rebuild()
RutaPublic.model_rebuild()