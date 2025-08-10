__includes["aplicacion.nls" "mpi_io.nls" "adio.nls" "ad_pvfs.nls" "system_interface.nls" "job_cliente.nls" "flow_cliente.nls" "bmi_cliente.nls" "comunicacion.nls"
  "main_loop.nls" "job_servidor.nls" "flow_servidor.nls" "bmi_servidor.nls" "trove.nls" "mdt_main_loop.nls" "regresion.nls"]

globals[
  tiempo_respuesta_max
  interacciones
  operations_number
  time_function
  number_of_storage_nodes
]


;;Creacion de agentes
;computo-patches
breed [computo-patches]
;;agentes nodo cliente
breed [apps app]
breed [mpi_ mpi_io]
breed [adios adio]
breed [ad_pvfss ad_pvfs]
;;agentes lado cliente
breed [system_interfaces system_interface]
breed [jobs job]
breed [flows flow]
breed [bmis bmi]
;;agentes correspondiente a la gestion de operaciones en la capa SYSTEM INTERFACE
breed [pvfs_rws pvfs_rw]
breed [pvfs_getattrs pvfs_getattr]
breed [pvfs_opens pvfs_open]
breed [pvfs_flushs pvfs_flush]

;;agentes lado servidor ;;dataserver
breed [main_loops main_loop]
breed [jobs_servidor job_s]
breed [flows_servidor flow_s]
breed [bmis_servidor bmi_s]
breed [troves trove]
;;agentes correspondientes a la gestion de las operaciones en la capa MAIN LOOP
breed [ml_creations ml_creation]
breed [ml_reads ml_read]
breed [ml_rws ml_rw]
breed [ml_flushs ml_flush]

;;agentes lado servidor ;;metadaserver
breed [mdt_main_loops mdt_main_loop]
breed [mdt_jobs_servidor mdt_job_s]
breed [mdt_flows_servidor mdt_flow_s]
breed [mdt_bmis_servidor mdt_bmi_s]
breed [mdt_troves mdt_trove]
;;;agentes correspondientes a la gestion de las operaciones en la capa MAIN LOOP en metadataserver
breed [mdt_ml_creations mdt_ml_creation]
breed [mdt_ml_reads mdt_ml_read]
breed [mdt_ml_rws mdt_ml_rw]
breed [mdt_ml_flushs mdt_ml_flush]

;;en construccion
breed [discos disco]

;;agente que guarda salida en formato csv
breed [datas data]


;;;;;;;;;;;;;;;;;;;;;;;;;;LADO CLIENTE;;;;;;;;;;;;;;;;;;;;;;;;;

apps-own[
  capainf ;agente mpi-io
  num_solicitudes ;numero de solicitudes (aleatorio)
  operacion_app ;tipo de comando de la solicitud entrante
  respuestas ;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  finalizo?
]

mpi_-own[
  capasup ;agente app
  capainf ;agente adio
  solicitud_procesando ;variable donde se almacena la solicitud procesando
  solicitudes ;lista donde se guardan las solicitudes entrantes
  respuestas ;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
]

adios-own[
  capasup ;agente mpi-io
  capainf ;agente ad_pvfs
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;lista de solicitudes entrantes
  respuestas ;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta agente
]

ad_pvfss-own[
  capasup ;agente adio
  capainf ; agente system interface
  solicitud_procesando ;variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;lista de solicitudes entrantes
  respuestas ;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta agente
]

system_interfaces-own[
  capainf ;agente job
  solicitud_procesando ;variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;lista de solicitudes entrantes
  respuestas ;lista de respuestas entrantes
  buffer ;lista de solicitudes atendidas a las cuales se gestionado la maquina de estados correspondiente (no utilizable por el momento)
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

jobs-own[
  capasup ;agente system interface
  id_j ;variable que almacena el id del job que se encuentra gestionando
  capainf_b ;agente bmi
  capainf_f ;agente flow
  solicitud_procesando ;variable donde se almacena la solicitud que se encuentra procesando
  operacion_global ;variable que almace la operacion a ejecutar para que pueda ser accedidad globalmente por la maquina de estados
  confirmacion_bmi? ;boolean de recibimiento de la respuesta requerida de la capa bmi
  solicitudes ;lista de solicitudes entrantes
  buffer ;almacena las solicitudes que se encuentran completando que representan a los JOBs publicados que hay que monitorear
  respuestas ;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_job
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

flows-own[
  capasup ;agente job
  capainf_b ;agente bmi
  id_flow ;almacena el id del flow que se encuentra gestionando
  f_callback ;almacena la funcion callback a gestionar
  solicitud_procesando ;variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;lista de solicitudes entrantes
  respuestas ;lista de respuestas entrantes
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_flow
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

bmis-own[
  capasup_j ;agente job
  capasup_f ;agente flow
  solicitudes ;lista de solicitudes entrantes
  respuestas ;lista de respuestas entrantes
  solicitud_procesando ;variable donde se almacena la solicitud que se encuentra procesando
  comunicar_operacion_send_bmi? ;boolean que indica si se debe comunicar el procesamiento de la operacion
  comunicar_operacion_recv_bmi? ;boolean que indica si se debe comunicar el procesamiento de la operacion
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  estado ;almacen el estado actual
  mensajes ;lista de mensajes recibidos de agentes BMI servidor
  num_operacion_procesando ;numero de operacion que se encuentra procesando
  descripcion ;etiqueta del agente
  num_operacion_bmi
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

;;; agente que simula la gestion de la maquina de estados correspondiente a una operacion open
pvfs_opens-own[
  id_capasup ;id agente ad_pvfs solicitante
  id_system ;id agente system interface
  capainf_j ;agente job
  id_me_getattr ;id de la maquina de estados a la cual se le solicito los atributos
  id_bmi_servidor ;id del BMI servidor al que se le envio solicitud
  cod_error_operacion ; almacena la respuesta asociada al completarse la operacion
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  respuestas;; lista de respuesta entrantes
  estado ;almacena el estado actual
]

;;; agente que simula la gestion de la maquina de estados correspondiente a una operacion read o write
pvfs_rws-own[
  id_capasup ;id agente ad_pvfs solicitante
  id_system ;id agente system interface
  capainf_j ;agente job
  id_me_getattr ;id de la maquina de estados a la cual se le solicito los atributos
  id_bmi_servidor ;id del BMI servidor al que se le envio solicitud
  cod_error_operacion ; almacena la respuesta asociada al completarse la operacion
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  operacion_rw ;almacena la operacion a ejecutar (READ o WRITE)
  respuestas ;; lista de respuestas entrantes
  estado ;almacena el estado actual
]

pvfs_getattrs-own[
  id_me_solicitud ;;id agente solicitante
  id_system ;; id agente system interface
  capainf_j ;agente job
  id_bmi_servidor ;id del BMI servidor al que se le envio solicitud
  id_bmi_mdt_servidor ; id del metadata BMI server al que se le envia la solicitud
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  cod_error_operacion ; almacena la respuesta asociada al completarse la operacion
  respuestas ;; lista de respuestas entrantes
  estado ;almacena el estado actual
]

pvfs_flushs-own[
  id_capasup ;id agente ad_pvfs solicitante
  id_system ;id agente system interface
  capainf_j ;agente job
  id_me_getattr ;id de la maquina de estados a la cual se le solicito los atributos
  id_bmi_servidor ;id del BMI servidor al que se le envio solicitud
  cod_error_operacion ; almacena la respuesta asociada al completarse la operacion
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  operacion_flush ;almacena tipo operacion FLUSH a ejecutar (bstream o keyval)
  respuestas ;; lista de respuestas entrantes
  estado ;almacena el estado actual
]


;;;;;;;;;;;;;;;;;;;;;;;;LADO SERVIDOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main_loops-own[
  capainf ;agente job
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;lista de solicitudes entrantes
  ;solicitud_iniciar ;para eliminar problema de doble y pronta incicialización
  respuestas ;lista de respuestas entrantes
  buffer ;lista de solicitudes atendidas a las cuales se a gestionado la maquina de estados correspondiente
  estado ;almacena estado actual
  descripcion ;etiqueta del agente
  ;inicializado? ; para evitar doble inicialización
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
  inicializado?
]

jobs_servidor-own[
  id_j ;;variable que almacena el id del job que se encuentra gestionando
  capasup ; agente main loop
  capainf_f ;agente flow
  capainf_b ;agente bmi
  capainf_t ;agente trove
  confirmacion_bmi? ;boolean confirma la recepcion de la respuesta (test) de la capa bmi
  confirmacion_trove? ;boolean confirma la recepcion de la respuesta (test) de la capa trove
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  buffer ;;almacena las solicitudes que se encuentran completando que representan a los JOBs publicados que hay que monitorear
  respuestas ;; lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_job_servidor
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

flows_servidor-own[
  id_flow ; id del flow que se encuentra gestionando
  capasup ;agente job
  capainf_b ;agente bmi
  capainf_t ;agente trove
  operacion_gloabl; donde se almacena operacion gloabl
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  respuestas;;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_flow_servidor
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

bmis_servidor-own[
  capasup_j ;;agente job
  capasup_f ;agente flow
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  mensajes ;lista de mensajes provenientes de agentes BMI cliente
  num_operacion_procesando ;id de la operacion que se se debe procesar
  comunicar_operacion_send_bmi? ;boolean que indica si se debe comunicar la operacion a capa superiores
  comunicar_operacion_recv_bmi? ;boolean que indica si se debe comunicar la operacion a capa superiores
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  respuestas;;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_bmi_servidor
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

troves-own[
  capasup_j ; id agente job
  capasup_f ; id agente flow
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  num_operacion_procesando ;id de la operacion que se se debe procesar
  comunicar_operacion_read_trove? ;boolean que indica si se debe comunicar la operacion a capa superiores
  comunicar_operacion_write_trove? ;boolean que indica si se debe comunicar la operacion a capa superiores
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  respuestas;;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_trove
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]


;;; agente que simula la gestion de la maquina de estados correspondiente a una operacion open
ml_creations-own[
  id_bmi_cliente ;id bmi cliente
  mainloop ; id agente system interface
  capainf_j ;agente job
  respuestas;; lista de respuesta entrantes
  comando;; tipo de operacion
  estado ;almacena el estado actual
  id_mjs ;id del agente system interface de donde proviene la solicitud
]

;;; agente que simula la gestion de la maquina de estados correspondiente a una operacion read o write
ml_rws-own[
  id_bmi_cliente ;id del agente bmi cliente
  mainloop ;; id de capa system interface
  capainf_j ;;iagente job
  operacion_rw ;almacena la operacion a ejecutar
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  respuestas ;; lista de respuestas
  estado ;almacena el estado actual
  ack? ;boolean que almacena si el archivo se encuentra o no
  id_mjs ;id del agente system interface de donde proviene la solicitud
]

ml_reads-own[
  id_bmi_cliente ;id del agente bmi cliente
  mainloop ;; id de capa system interface
  capainf_j ;agente capa job
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  respuestas ;; lista de respuesta
  estado ;almacena el estado actual
  ack? ;boolean que almacena si el archivo se encuentra o no
  id_mjs ;id del agente system interface de donde proviene la solicitud
]

ml_flushs-own[
  id_bmi_cliente ;id del agente bmi cliente
  mainloop ;; id de capa system interface
  capainf_j ;;iagente job
  operacion_flush ;almacena la operacion a ejecutar
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  respuestas ;; lista de respuestas
  estado ;almacena el estado actual
  ack? ;boolean que almacena si el archivo se encuentra o no
  id_mjs ;id del agente system interface de donde proviene la solicitud
]

datas-own[
  id_proc ;id del proceso - por el momento toma el de la capa
  capa ;nombre de la capa
  funciones_tiempos ;lista de funciones con tiempo
  tiempo ;tiempo de la funcion. Se obtiene de la carpeta times
  paquete ;lista con el paquete completo (capa; funciones_tiempos)
  estado ;almacena el estado actual
  capainf
  respuestas
  id_app
  ;funcion ;relacion matematica. tecnica de regresion
  ;aleatorio ;valor random. desvio estandar
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;,LADO METADATA SERVER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mdt_main_loops-own[
  capainf ;agente job
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;lista de solicitudes entrantes
  ;solicitud_iniciar ;para eliminar problema de doble y pronta incicialización
  respuestas ;lista de respuestas entrantes
  buffer ;lista de solicitudes atendidas a las cuales se a gestionado la maquina de estados correspondiente
  estado ;almacena estado actual
  descripcion ;etiqueta del agente
  ;inicializado? ; para evitar doble inicialización
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
  inicializado?
]

mdt_jobs_servidor-own[
  id_j ;;variable que almacena el id del job que se encuentra gestionando
  capasup ; agente main loop
  capainf_f ;agente flow
  capainf_b ;agente bmi
  capainf_t ;agente trove
  confirmacion_bmi? ;boolean confirma la recepcion de la respuesta (test) de la capa bmi
  confirmacion_trove? ;boolean confirma la recepcion de la respuesta (test) de la capa trove
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  buffer ;;almacena las solicitudes que se encuentran completando que representan a los JOBs publicados que hay que monitorear
  respuestas ;; lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_job_servidor
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

mdt_flows_servidor-own[
  id_flow ; id del flow que se encuentra gestionando
  capasup ;agente job
  capainf_b ;agente bmi
  capainf_t ;agente trove
  operacion_gloabl; donde se almacena operacion gloabl
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  respuestas;;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_flow_servidor
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

mdt_bmis_servidor-own[
  capasup_j ;;agente job
  capasup_f ;agente flow
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  mensajes ;lista de mensajes provenientes de agentes BMI cliente
  num_operacion_procesando ;id de la operacion que se se debe procesar
  comunicar_operacion_send_bmi? ;boolean que indica si se debe comunicar la operacion a capa superiores
  comunicar_operacion_recv_bmi? ;boolean que indica si se debe comunicar la operacion a capa superiores
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  respuestas;;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_bmi_servidor
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

mdt_troves-own[
  capasup_j ; id agente job
  capasup_f ; id agente flow
  solicitud_procesando ;; variable donde se almacena la solicitud que se encuentra procesando
  solicitudes ;;lista de solicitudes entrantes
  num_operacion_procesando ;id de la operacion que se se debe procesar
  comunicar_operacion_read_trove? ;boolean que indica si se debe comunicar la operacion a capa superiores
  comunicar_operacion_write_trove? ;boolean que indica si se debe comunicar la operacion a capa superiores
  buffer ;almacena las solicitudes que se encuentran en proceso de completarse
  respuestas;;lista de respuestas entrantes
  estado ;almacena el estado actual
  descripcion ;etiqueta del agente
  num_operacion_trove
  nodo_id ;;guarda id del nodo app correspondiente a cada IO node
]

;;; agente que simula la gestion de la maquina de estados correspondiente a una operacion open
mdt_ml_creations-own[
  id_bmi_cliente ;id bmi cliente
  mainloop ; id agente system interface
  capainf_j ;agente job
  respuestas;; lista de respuesta entrantes
  comando;; tipo de operacion
  estado ;almacena el estado actual
  id_mjs ;id del agente system interface de donde proviene la solicitud
]

;;; agente que simula la gestion de la maquina de estados correspondiente a una operacion read o write
mdt_ml_rws-own[
  id_bmi_cliente ;id del agente bmi cliente
  mainloop ;; id de capa system interface
  capainf_j ;;iagente job
  operacion_rw ;almacena la operacion a ejecutar
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  respuestas ;; lista de respuestas
  estado ;almacena el estado actual
  ack? ;boolean que almacena si el archivo se encuentra o no
  id_mjs ;id del agente system interface de donde proviene la solicitud
]

mdt_ml_reads-own[
  id_bmi_cliente ;id del agente bmi cliente
  mainloop ;; id de capa system interface
  capainf_j ;agente capa job
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  respuestas ;; lista de respuesta
  estado ;almacena el estado actual
  ack? ;boolean que almacena si el archivo se encuentra o no
  id_mjs ;id del agente system interface de donde proviene la solicitud
]

mdt_ml_flushs-own[
  id_bmi_cliente ;id del agente bmi cliente
  mainloop ;; id de capa system interface
  capainf_j ;;iagente job
  operacion_flush ;almacena la operacion a ejecutar
  solicitud_recv_enviada? ;;boolean que gestiona el envio de solicitud recepcion
  solicitud_send_enviada? ;;boolean para gestionar el envio de solicitud envio
  respuestas ;; lista de respuestas
  estado ;almacena el estado actual
  ack? ;boolean que almacena si el archivo se encuentra o no
  id_mjs ;id del agente system interface de donde proviene la solicitud
]


;;Setup
;;configuracion del escenario


to setup

  clear-all
  set operations_number 1
  guardar_configuracion
  crear_header
  set number_of_storage_nodes number_of_compute_nodes


  create-apps number_of_compute_nodes
  create-mpi_ number_of_compute_nodes
  create-adios number_of_compute_nodes
  create-ad_pvfss number_of_compute_nodes
  create-system_interfaces number_of_compute_nodes
  create-jobs number_of_compute_nodes
  create-flows number_of_compute_nodes
  create-bmis number_of_compute_nodes

  create-main_loops number_of_compute_nodes
  create-jobs_servidor number_of_compute_nodes
  create-flows_servidor number_of_compute_nodes
  create-bmis_servidor number_of_compute_nodes
  create-troves number_of_compute_nodes

  create-mdt_main_loops number_of_metadata_servers
  create-mdt_jobs_servidor number_of_metadata_servers
  create-mdt_flows_servidor number_of_metadata_servers
  create-mdt_bmis_servidor number_of_metadata_servers
  create-mdt_troves number_of_metadata_servers

  configurar_variables_principales

  ask turtles[
    set size 5
    set color 74
    set shape "rectangle"
  ]

  ask patches [set pcolor white]

  ask apps[
    set descripcion "APP"
    set capainf nobody
    set color red + 1
  ]

  ask mpi_[
    set capasup nobody
    set descripcion "MPI-IO"
    set color sky
  ]


  ask ad_pvfss[
    set descripcion "AD_PVFS"
    set capasup nobody
    set color sky
  ]

  ask adios[
    set descripcion "ADIO"
    set capasup nobody
    set color sky
  ]

  ask system_interfaces[
    set descripcion "SI"
    set capainf nobody
    set color green + 1
  ]

  ask jobs[
    set capasup nobody
    set descripcion "JOB"
    set color green + 1
  ]


  ask flows[
    set descripcion "FLOW"
    set capasup nobody
    set color green + 1
  ]

  ask bmis[
    set capasup_j nobody
    set capasup_f nobody
    set descripcion "BMI"
    set color green + 1
  ]


  ask main_loops[
    set descripcion "ML"
    set capainf nobody ;;;;;
    set color violet + 1
    set inicializado? false
  ]

  ask jobs_servidor[
    set descripcion "JOB"
    set capasup nobody
    set color violet + 1
  ]


  ask flows_servidor[
    set descripcion "FLOW"
    set capasup nobody
    set color violet + 1

  ]

  ask bmis_servidor[
    set descripcion "BMI"
    set capasup_j nobody
    set capasup_f nobody
    set color violet + 1
  ]

  ask troves[
    set descripcion "TROVE"
    set capasup_j nobody
    set color violet + 1
  ]


  ask one-of apps[
    set size 7
    ;configurar_agente -26 15 8.5 5.5 2.5 false 7]
    configurar_agente -31 10 5 2.5 0 false 6]

  ask apps[
    if(capainf = nobody)[
      ;let x -12 + count apps with [capainf != nobody]
      let x ( count apps with [capainf != nobody]) * 10 - 26
      ;show x
      configurar_agente x 13 11 0 0 true 4]
  ]

  ask one-of main_loops[
    configurar_agentes_servidor -40 -3.5 -6.5 -9.5 -12.5 -15.5 7 false
  ]

  ask main_loops[
    if (capainf = nobody)[
      ;configurar_agentes_servidor -10 -3.5 -6.5 -9.5 -12.5 -15.5 7
      ;let x (- 11 + ( count main_loops with [capainf != nobody]) * 20 )
      ;show x
      configurar_agentes_servidor -26 7 11.3 9.6 7.9 6.2 4 true
      ;configurar_agentes_servidor -20 -3.5 -6.5 -9.5 -12.5 -15.5 7 false
    ]
  ]

  ask mdt_main_loops[
    set descripcion "MDT-ML"
    set capainf nobody ;;;;;
    set color violet + 1
    set inicializado? false
  ]

  ask mdt_jobs_servidor[
    set descripcion "MDT-JOB"
    set capasup nobody
    set color violet + 1
  ]


  ask mdt_flows_servidor[
    set descripcion "MDT-FLOW"
    set capasup nobody
    set color violet + 1

  ]

  ask mdt_bmis_servidor[
    set descripcion "MDT-BMI"
    set capasup_j nobody
    set capasup_f nobody
    set color violet + 1
  ]

  ask mdt_troves[
    set descripcion "MDT-TROVE"
    set capasup_j nobody
    set color violet + 1
  ]

  ask mdt_main_loops[
    if (capainf = nobody)[
      ;configurar_agentes_servidor -10 -3.5 -6.5 -9.5 -12.5 -15.5 7
      ;let x (- 11 + ( count mdt_main_loops with [capainf != nobody]) * 20 )
      ;show x
      ;configurar_agentes_servidor -26 7 11.3 9.6 7.9 6.2 4 true
      configurar_agentes_servidor_mdt -13 -3.5 -6.5 -9.5 -12.5 -15.5 7 false
      ;configurar_agentes_servidor -26 7 11.3 9.6 7.9 6.2 4 true
    ]
  ]

  reset-ticks

  ask patches [
    set plabel-color black]


  ask patches with [(pxcor >= -37 and pycor >= -20) and (pxcor <= -26 and pycor <= 15)][
    set pcolor black + 6 ]

  ;nodo computo
  ask patches with [(pxcor >= -20 and pycor <= 15) and (pxcor <= 36 and pycor >= 5)][
    set pcolor gray + 3]

;  ask patches with [(pxcor >= -36 and pycor >= 13) and (pxcor <= -20 and pycor <= 17)][
;    set pcolor pink + 3]
;
;  ;nodo mpi
;  ask patches with [(pxcor >= -36 and pycor >= 1) and (pxcor <= -20 and pycor <= 10)][
;    set pcolor cyan + 3 ]
;
;  ;;nodo i/o
;  ask patches with [(pxcor >= -36 and pycor <= -2) and (pxcor <= -20 and pycor >= -14)][
;    set pcolor lime + 4 ]

  ;;;;nodo storage
  ask patches with [(pxcor >= -26 and pycor <= 0) and (pxcor <= -13 and pycor >= -18)][
    set pcolor black + 6 ]

  ;;bus
   ask patches with [(pxcor >= -12 and pycor <= -12) and (pxcor <= -8 and  pycor >= -13)][
    set pcolor blue + 3]
   ask patches with [(pxcor >= -8 and pycor <= 2) and (pxcor <= -6.5 and pycor >= -13)][
    set pcolor blue + 3]
   ask patches with [(pxcor >= -8 and pycor <= 3) and (pxcor <= 13 and pycor >= 1.5)][
    set pcolor blue + 3]
   ask patches with [(pxcor >= 7 and pycor >= 2) and (pxcor <= 8.5 and pycor <= 4)][
    set pcolor blue + 3]
   ask patches with [(pxcor >= 13 and pycor >= -5) and (pxcor <= 14.5 and pycor <= 3)][
     set pcolor blue + 3]

   ;;metadataservers
   ask patches with [(pxcor >= -3 and pycor <= 0) and (pxcor <= 36 and pycor >= -18)][
    set pcolor gray + 3]



  ask patch 10 16[
    set plabel "COMPUTE NODES"
  ]


;  ask patch -20 -2[
;    set plabel "I/O CLIENT"
;  ]
;

  ask patch 20 1[
    set plabel "METADATA SERVERS"

  ]

;  ask patch 34 13[
;    set plabel "APPS"
;  ]
;  ask patch 34 11[
;    set plabel "MPIS"
;  ]
;  ask patch 35 9[
;    set plabel "I/O CLIENTS"
;  ]

  ask patch -10 2[
    set plabel "BUS"
  ]

   ask links[
    set color black
    set thickness 0.1
  ]

   reset-timer

end


;;ejecucion de maquina de estados de cada agente
to start
  ask-concurrent turtles [
    run estado
  ]
  if(count apps with[finalizo? = true] = number_of_compute_nodes)[
       stop
  ]
end

to results
    file-open "salida_io.txt"
    print file-read-line
    file-close
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Guardar en Archivo datos.txt;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to guardar_configuracion
  file-open "datos.txt"
  file-write "Mensaje-Respuesta-a App Nº"
  file-write "tiempo respuesta"
  file-write (word "Datos en sistema: " data_in_system)
  file-write (word "Cantidad codigo a ejecutar: " operations_number)
  file-print ";"
  file-close
end

to guardar_mensaje_respuesta_archivo
  let tiempo_aux timer
  if(tiempo_aux > tiempo_respuesta_max)[set tiempo_respuesta_max tiempo_aux]
  file-open "datos.txt"
  file-write who
  file-write tiempo_aux
  file-write operacion_app
  file-print ";"
  file-close
end

to crear_header
  if(file-exists? "output.txt" = true)[
    file-delete "output.txt"]
  file-open "output.txt"
  file-print (word "####################### Operacion " type_command " " date-and-time " ####################")
  file-write "Id proceso"
  file-write "Nodo"
  file-write "Capa"
  file-write "Funcion"
  file-write "Tiempo"
  file-print ";"
  file-close
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PERMITEN CONFIGURAR LA PANTALLA EN DONDE SE VISUALIZARA LA SIMULACION EN LA INTERFAZ;;;;;;;;;;;;;;;;;;;
;;configura las variables principales de los agentes y que se utilizaran en la simulacion
to configurar_variables_principales

  set time_function []
  set interacciones operations_number
  set tiempo_respuesta_max 0


    ask apps[
    set estado task esperar_app
    ;set num_solicitudes random operations_number
    ;if(num_solicitudes = 0)[set num_solicitudes 1]
    set num_solicitudes 1
    set respuestas []
    set finalizo? false
  ]

  ask mpi_[
    set estado task esperar_mpiio
    set respuestas []
    set solicitudes []
  ]


  ask ad_pvfss[
    set estado task esperar_ad_pvfs
    set respuestas []
    set solicitudes []
    set color sky
  ]

  ask adios[
    set estado task esperar_adio
    set respuestas []
    set solicitudes []
  ]

  ask system_interfaces[
    set estado task esperar_system
    set respuestas []
    set solicitudes []
    set buffer []
  ]

  ask jobs[
    set estado task esperar_job
    set respuestas []
    set solicitudes []
    set buffer []
    set confirmacion_bmi? false
    set num_operacion_job 100
  ]


  ask flows[
    set estado task esperar_flow
    set respuestas []
    set solicitudes []
    set buffer []
    set num_operacion_flow 100
  ]

  ask bmis[
    set estado task esperar_bmi
    set respuestas []
    set solicitudes []
    set mensajes []
    set buffer []
    set comunicar_operacion_send_bmi? false
    set comunicar_operacion_recv_bmi? false
    set num_operacion_bmi 100
  ]


  ask main_loops[
    set estado task esperar_main_loop
    set respuestas []
    set solicitudes []
    ;if (inicializado? = false)[
      set solicitudes lput (list 0 0 0 "iniciar") solicitudes
      ;]
    set buffer []
  ]

  ask jobs_servidor[
    set estado task esperar_job_servidor
    set confirmacion_bmi? false
    set confirmacion_trove? false
    set respuestas []
    set solicitudes []
    set buffer []
    set num_operacion_job_servidor 100
  ]


  ask flows_servidor[
    set estado task esperar_flow_s
    set respuestas []
    set solicitudes []
    set buffer []
    set num_operacion_flow_servidor 100
  ]

  ask bmis_servidor[
    set estado task esperar_bmi_s
    set respuestas []
    set solicitudes []
    set mensajes[]
    set buffer []
    set comunicar_operacion_send_bmi? false
    set comunicar_operacion_recv_bmi? false
    set num_operacion_bmi_servidor 100

  ]

  ask troves[
    set estado task esperar_trove
    set respuestas []
    set solicitudes []
    set buffer []
    set num_operacion_trove 100
  ]

  ;;;;;;;;;;;;;;;;;;;;
   ask mdt_main_loops[
    set estado task esperar_mdt_main_loop
    set respuestas []
    set solicitudes []
    ;if (inicializado? = false)[
      set solicitudes lput (list 0 0 0 "iniciar") solicitudes
      ;]
    set buffer []
  ]

  ask mdt_jobs_servidor[
    set estado task esperar_job_servidor
    set confirmacion_bmi? false
    set confirmacion_trove? false
    set respuestas []
    set solicitudes []
    set buffer []
    set num_operacion_job_servidor 100
  ]


  ask mdt_flows_servidor[
    set estado task esperar_flow_s
    set respuestas []
    set solicitudes []
    set buffer []
    set num_operacion_flow_servidor 100
  ]

  ask mdt_bmis_servidor[
    set estado task esperar_bmi_s
    set respuestas []
    set solicitudes []
    set mensajes[]
    set buffer []
    set comunicar_operacion_send_bmi? false
    set comunicar_operacion_recv_bmi? false
    set num_operacion_bmi_servidor 100

  ]

  ask mdt_troves[
    set estado task esperar_trove
    set respuestas []
    set solicitudes []
    set buffer []
    set num_operacion_trove 100
  ]
end


;Permite asociar a cada uno de los agentes para definir cual de ellos es la capa superior e inferior respectivamente (NODOS COMPUTO)
to configurar_agente [x y y1 y2 y3 oculto? tamaño]
  setxy (x) (y) ;15
  set size tamaño
  if(oculto? = false)[agregar_etiqueta -35 y]
  set capainf one-of mpi_ with [capasup = nobody]
  let id_a self
  if(oculto? = false)[
    create-link-with capainf]
  if(count apps with [capainf = nobody] < (number_of_compute_nodes - 10))[
    set hidden? true
  ]
  ;capa mpi
  ask capainf[
    set capasup id_a
    set size tamaño
    if(oculto? = false)[agregar_etiqueta -35 y1]
    set hidden? [hidden?] of capasup
    setxy [xcor] of capasup y1
    set capainf one-of adios with [capasup = nobody]
    let id_m self
    ;capa adio
    ask capainf[
      set capasup id_m
      set size tamaño
      if(oculto? = false)[agregar_etiqueta -35 y2]
      setxy [xcor] of capasup y2
      set hidden? oculto?
      set capainf one-of ad_pvfss with [capasup = nobody]
      let id_ad self
      ;capa ad_pvfs
      ask capainf[
        set size tamaño
        set capasup id_ad
        if(oculto? = false)[agregar_etiqueta -35 y3]
        setxy [xcor] of capasup y3
        set hidden? oculto?
        set capainf one-of system_interfaces with [capainf = nobody]
        if(oculto? = false)[
        create-link-with capainf]
        ask capainf[
          ifelse(oculto? = false)[
            configurar_agentes_cliente x -4.5 -7 -9.5 -12 false tamaño]
          [
            configurar_agentes_cliente x (y - 4) (y - 6) 0 0 true tamaño
            ;configurar_agentes_cliente x (y - 1) (y - 3) 0 0 true tamaño
          ]
        ]
      ]
    ]
  ]
end


;Permite asociar a cada uno de los agentes para definir cual de ellos es la capa superior e inferior respectivamente (NODOS I/O)
to configurar_agentes_cliente [x y y1 y2 y3 oculto? tamaño]
  setxy (x) (y);3
  set size tamaño
  set capainf one-of jobs with [capasup = nobody]
  let id_si self
  if(oculto? = false)[agregar_etiqueta -35 y]
  if(count system_interfaces with [capainf = nobody] < (number_of_compute_nodes - 10))[
    set hidden? true
  ]
  ;capa jobs
  ask capainf[
    set capasup id_si
    set size tamaño
    setxy [xcor] of capasup y1
    if(oculto? = false)[agregar_etiqueta -35 y1]
    set hidden? oculto?
    set capainf_f one-of flows with [capasup = nobody]
    set capainf_b one-of bmis with [capasup_j = nobody]
    let id_job self
    ;capa flow
    ask capainf_f[
      set capasup id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta -35 y2]
      set capainf_b [capainf_b] of capasup
      set hidden? oculto?
      setxy [xcor] of capasup y2
    ]
    ;capa bmi
    ask capainf_b[
      set capasup_j id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta -35 y3]
      set capasup_f [capainf_f] of capasup_j
      set hidden? oculto?
      setxy [xcor] of capasup_j y3
    ]

  ]

end

;Permite asociar a cada uno de los agentes para definir cual de ellos es la capa superior e inferior respectivamente (NODOS SERVIDOR)
to configurar_agentes_servidor [x y y1 y2 y3 y4 tamaño oculto?]

  set capainf one-of jobs_servidor with [capasup = nobody]
  if(count main_loops-here > 3)[
    set hidden? false
  ]

  ifelse(oculto? = false)[ setxy -20 y] [setxy (x + (count main_loops-here * 10)) (y)] ;-8 -2
  ;setxy (x + (count main_loops-here )) (y) ;-8 -2
  set size tamaño
  if(oculto? = false)[
    agregar_etiqueta -15 y
    ask patch -19 (y + 2) [set plabel "data server"]
  ]
  let id self
  ask capainf[
    set capasup id
    setxy [xcor] of capasup y1
    set size tamaño
    if(oculto? = false)[agregar_etiqueta -15 y1]
    set hidden? oculto?
    set capainf_f one-of flows_servidor with [capasup = nobody]
    set capainf_b one-of bmis_servidor with [capasup_j = nobody]
    set capainf_t one-of troves with [capasup_j = nobody]
    let id_job self
    ask capainf_f[
      set capasup id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta -15 y2]
      set hidden? oculto?
      set capainf_b [capainf_b] of capasup
      set capainf_t [capainf_t] of capasup
      setxy [xcor] of capasup y2
    ]
    ask capainf_b[
      set capasup_j id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta -15 y3]
      set hidden? oculto?
      set capasup_f [capainf_f] of capasup_j
      setxy [xcor] of capasup_j y3
    ]
    ask capainf_t[
      set capasup_j id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta -15 y4]
      set hidden? oculto?
      set capasup_f [capainf_f] of capasup_j
      setxy [xcor] of capasup_j y4
    ]
  ]
end

to configurar_agentes_servidor_mdt [x y y1 y2 y3 y4 tamaño oculto?]

  set capainf one-of mdt_jobs_servidor with [capasup = nobody]
  if(count mdt_main_loops-here > 3)[
    set hidden? false
  ]

  ifelse(oculto? = false)[ setxy (x + (count mdt_main_loops-here * 15)) y] [setxy (x + (count mdt_main_loops-here * 10)) (y)] ;-8 -2
  ;setxy (x + (count main_loops-here )) (y) ;-8 -2
  set size tamaño
  if(oculto? = false)[
    agregar_etiqueta 7 y
    ;ask patch -4 (y + 2) [set plabel "metadata server"]
  ]
  let id self
  ask capainf[
    set capasup id
    setxy [xcor] of capasup y1
    set size tamaño
    if(oculto? = false)[agregar_etiqueta 7 y1]
    set hidden? oculto?
    set capainf_f one-of mdt_flows_servidor with [capasup = nobody]
    set capainf_b one-of mdt_bmis_servidor with [capasup_j = nobody]
    set capainf_t one-of mdt_troves with [capasup_j = nobody]
    let id_job self
    ask capainf_f[
      set capasup id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta 8 y2]
      set hidden? oculto?
      set capainf_b [capainf_b] of capasup
      set capainf_t [capainf_t] of capasup
      setxy [xcor] of capasup y2
    ]
    ask capainf_b[
      set capasup_j id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta 7 y3]
      set hidden? oculto?
      set capasup_f [capainf_f] of capasup_j
      setxy [xcor] of capasup_j y3
    ]
    ask capainf_t[
      set capasup_j id_job
      set size tamaño
      if(oculto? = false)[agregar_etiqueta 8 y4]
      set hidden? oculto?
      set capasup_f [capainf_f] of capasup_j
      setxy [xcor] of capasup_j y4
    ]
  ]
end

;Permite agregar la etiqueta al lado de cada agente para identificarlo
to agregar_etiqueta [x y]
  let texto descripcion
  ask patch x y[
    set plabel texto
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SIMULAR EL SINTETICO MEDIANTECOMMAND CENTER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Permiten generar la entrada y salida i/o utilizando command center tomando como variables( numero de nodos computo, numero nodos storage, repeticion, block_size, segment_count, unidades(mega kilo))
to io[variable1 variable4 variable5 variable6 ];variable2 variable4 variable5 variable6 ]
  let n substring (word variable1) 1 length (word variable1)
  ;let s substring (word variable2) 1 length (word variable2)
  ;let n_o substring (word variable3) 1 length (word variable3)
  let r substring (word variable4) 1 length (word variable4)
  let t substring (word variable5) 1 length (word variable5)
  let u substring (word variable6) 1 length (word variable6)
  ;let v substring (word variable7) 1 length (word variable7)
  set number_of_compute_nodes read-from-string n
  ;set number_of_storage_nodes read-from-string s
  ;set operations_number read-from-string n_o
  set repeticiones read-from-string r
  set block_size read-from-string t
  set segment_count read-from-string u
  ;if v = "m" [set unit "megabytes"]
  ;if v = "k" [set unit "kilobytes"]
end

;;seleccion de tipo de comando read
to -r
   set type_command "read"
end

;;seleccion de tipo de comando write
to -w
   set type_command "write"
end

;;Seleccion de tipo de comando open
to -o
   set type_command "open"
end

to -fb
  set type_command "flush_bstream"
end

to -fk
  set type_command "flush_keyval"
end

to -c
  set type_command "close"
end

;;seleccion de tipo de comando aleatorio
to -rw
   set type_command "random"
end

to -k
  set unit "kilobytes"
end

to -m
  set unit "megabytes"
end


;;ejecuta el codigo de simulacion
to -s
  setup
    loop[
      start
      if(count apps with[finalizo? = true] = number_of_compute_nodes)[
        set repeticiones repeticiones - 1
        if(repeticiones > 0)[
          configurar_variables_principales
        ]
        if(repeticiones = 0)[
          salidaio
          file-open "salida_io.txt"
          while[file-at-end? = false][
            print file-read-line
          ]
          file-close
         stop
        ]
      ]
    ]
  stop
end

;;configura y escribe la salida de la simulacion
to salidaio
  if(file-exists? "salida_io.txt" = true)[
    file-delete "salida_io.txt"]
  file-open "salida_io.txt"
  file-print ""
  file-print "Resumen:"
  file-print (word "Datos en sistema: " data_in_system)
  file-print (word "Cantidad codigo a ejecutar: " operations_number)
  file-print (word "Tipo operacion: " type_command)
  file-print (word "Nodos I/O: " number_of_compute_nodes)
  ;file-print (word "Nodos Storage: " number_of_storage_nodes)
  file-print (word "Metadataservers: " number_of_metadata_servers)
  ;file-print (word "tiempo-maximo: " tiempo_respuesta_max)
  file-print (word "Tiempo total: " sum time_function)
  file-print "Cantidad de procesos por nodo: 1"
  file-print "Access: file-per-process"
  file-print "FileSystem: pvfs2"
  file-print (word "BlockSize: " block_size " " unit)
  file-print (word "SegmentCount: " segment_count)
  let file_size segment_count * block_size * number_of_compute_nodes
  file-print (word "Tamaño archivo: " file_size " " unit)
  file-print (word "Max " type_command " - (bw): " (file_size / sum time_function) " " unit "/sec" )
  file-close

end
@#$#@#$#@
GRAPHICS-WINDOW
262
12
1772
783
37
18
20.0
1
10
1
1
1
0
1
1
1
-37
37
-18
18
0
0
1
ticks
30.0

BUTTON
31
367
94
409
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
118
368
203
412
start
start
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

CHOOSER
126
307
229
352
data_in_system
data_in_system
"In_cache" "No_cache"
0

MONITOR
28
447
210
492
maximum response time
tiempo_respuesta_max
10
1
11

CHOOSER
51
243
201
288
type_command
type_command
"read" "write" "open" "close" "random"
0

CHOOSER
23
307
115
352
exists_file?
exists_file?
true false
0

SLIDER
21
146
257
179
number_of_compute_nodes
number_of_compute_nodes
0
7
5
1
1
NIL
HORIZONTAL

INPUTBOX
45
504
200
564
repeticiones
0
1
0
Number

INPUTBOX
28
74
112
134
block_size
819.2
1
0
Number

INPUTBOX
140
75
225
135
segment_count
1
1
0
Number

CHOOSER
59
10
197
55
unit
unit
"kilobytes" "megabytes"
1

SLIDER
21
192
256
225
number_of_metadata_servers
number_of_metadata_servers
0
3
1
1
1
NIL
HORIZONTAL

@#$#@#$#@
## Que es?

Es un modelo basado en la interaccion Aplicacion-Sistema Archivos-Disco.


## Modelo

Setup: establece la configuracion a ejecutar

Comenzar: ejecucion de la simulacion de acuerdo a los parametros establecidos en la configuracion

Variables


Agentes

Cada agente posee una variable ESTADO la cual contiene el valor con respecto al estado actual de acuerdo a su maquina de estados. La primitiva run ejecuta el estado que posea el agente ese determinado momento.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

rectangle
false
0
Rectangle -7500403 true true 45 105 255 195
Rectangle -16777216 false false 30 90 270 210

rectangle 2
true
0
Rectangle -7500403 false true 60 60 240 120
Rectangle -7500403 false true 45 45 255 135

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experimento_1" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>start</go>
    <final>file-open "datos.txt"
while[file-at-end? = false][
 print file-read-line
]
file-close</final>
    <metric>tiempo_respuesta_max</metric>
    <enumeratedValueSet variable="operations_number">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_compute_nodes">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_storage_nodes">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type_command">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data_in_system">
      <value value="&quot;In_cache&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exists_file?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimento_2" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>start</go>
    <final>file-open "datos.txt"
while [file-at-end? = False][
 print file-read-line
]
file-close</final>
    <metric>tiempo_respuesta_max</metric>
    <enumeratedValueSet variable="number_of_compute_nodes">
      <value value="2"/>
      <value value="5"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="data_in_system">
      <value value="&quot;In_cache&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="exists_file?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="type_command">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_of_storage_nodes">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="operations_number">
      <value value="2"/>
      <value value="5"/>
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

flecha
0.0
-0.2 1 1.0 0.0
0.0 1 1.0 0.0
0.2 1 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
