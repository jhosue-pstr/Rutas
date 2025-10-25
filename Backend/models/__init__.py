from .ruta import Ruta, RutaCreate, RutaPublic, RutaUpdate
from .punto_ruta import PuntoRuta, PuntoRutaCreate, PuntoRutaPublic, PuntoRutaUpdate
from .chofer import Chofer, ChoferCreate, ChoferPublic, ChoferUpdate
from .bus import Bus, BusCreate, BusPublic, BusUpdate

# Rebuild para resolver forward references
from .ruta import RutaPublic
from .punto_ruta import PuntoRutaPublic
from .chofer import ChoferPublic
from .bus import BusPublic

RutaPublic.model_rebuild()
PuntoRutaPublic.model_rebuild() 
ChoferPublic.model_rebuild()
BusPublic.model_rebuild()