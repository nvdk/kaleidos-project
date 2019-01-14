(in-package :mu-cl-resources)

;;;;
;; NOTE
;; docker-compose stop; docker-compose rm; docker-compose up
;; after altering this file.

;; Describe your resources here

(define-resource case ()
  :class (s-prefix "dbpedia:Case")
  :properties `((:public :boolean ,(s-prefix "vo-besluit:actieveOpenbaarheid"))
                (:created :date ,(s-prefix "dct:created"))
                (:archived :boolean ,(s-prefix "vo-besluit:gearchiveerd"))
                (:short-title :string ,(s-prefix "vo-besluit:korteTitel"))
                (:number :string ,(s-prefix "vo-besluit:nummer"))
                (:remark :string ,(s-prefix "vo-besluit:opmerking"))
                (:title :string ,(s-prefix "dct:title")))
  :has-many `((thema :via ,(s-prefix "dct:subject")
                     :as "thema")
              (capacity :via ,(s-prefix "vo-besluit:bevoegde")
                            :as "bevoegde"))
  :has-one `((dossiertype :via ,(s-prefix "dct:type")
                          :as "dossierType")
             (capacity :via ,(s-prefix "vo-besluit:contact")
                           :as "dossierType")
             (capacity :via ,(s-prefix "vo-besluit:indiener")
                       :as "indiener")
             (capacity :via ,(s-prefix "dct:creator")
                       :as "creator"))
  :resource-base (s-url "http://localhost/vo/dossiers/")
  :on-path "cases")


(define-resource dossiertype ()
  :class (s-prefix "ext:DossierType")
  :properties `((:naam :string ,(s-prefix "skos:prefLabel")))
  :has-many `((case :via ,(s-prefix "dct:type")
                       :inverse t
                       :as "cases"))
  :resource-base (s-url "http://localhost/vo/dossiertypes/")
  :on-path "dossiertypes")

(define-resource theme ()
  :class (s-prefix "ext:DossierThema")
  :properties `((:naam :string ,(s-prefix "skos:prefLabel")))
  :has-many `((case :via ,(s-prefix "vo-besluit:dossierThema")
                       :inverse t
                       :as "cases"))
  :resource-base (s-url "http://localhost/vo/dossierthemas/")
  :on-path "themes")


(define-resource capacity ()
  :class (s-prefix "vo-org:Hoedanigheid")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :has-many `((theme :via ,(s-prefix "vo-besluit:dossierThema")
                     :as "themes")
              (case :via ,(s-prefix "vo-besluit:contact")
                       :inverse t
                       :as "contactFor")
              (case :via ,(s-prefix "vo-besluit:bevoegde")
                       :inverse t
                       :as "responsibleFor")
              (case :via ,(s-prefix "vo-besluit:indiener")
                       :inverse t
                       :as "submitted")
              (case :via ,(s-prefix "dct:creator")
                       :inverse t
                       :as "creatorFor")
              )
  :has-one `((domain :via ,(s-prefix "vo-org:beleidsDomein")
                            :as "domain")
             (responsibility :via ,(s-prefix "vo-org:bevoegdheid")
                          :as "responsibility"))
  :resource-base (s-url "http://localhost/vo/capacities/")
  :on-path "capacities")

(define-resource domain ()
  :class (s-prefix "ext:BeleidsDomein")
  :properties `((:naam :string ,(s-prefix "skos:prefLabel")))
  :has-many `((capacity :via ,(s-prefix "vo-org:beleidsDomein")
                            :inverse t
                            :as "capacities"))
  :resource-base (s-url "http://localhost/vo/beleidsdomeinen/")
  :on-path "domains")

(define-resource responsibility ()
  :class (s-prefix "ext:Bevoegdheid")
  :properties `((:naam :string ,(s-prefix "skos:prefLabel")))
  :has-many `((capacity :via ,(s-prefix "vo-besluit:bevoegdheid")
                        :inverse t
                        :as "capacities"))
  :resource-base (s-url "http://localhost/vo/bevoegdheden/")
  :on-path "responsibilities")


(define-resource session ()
  :class (s-prefix "vo-besluit:Zitting")
  :properties `((:plannedstart :date ,(s-prefix "vo-gen:geplandeStart"))
                (:started-at :date ,(s-prefix "prov-o:startedAtTime"))
                (:ended-at :date ,(s-prefix "prov-o:endedAtTime"))
                (:number :string ,(s-prefix "vo-besluit:number")))
  :has-many `((agenda :via ,(s-prefix "ext:agenda")
                        :as "agendas"))
  :resource-base (s-url "http://localhost/vo/zittingen/")
  :on-path "sessions")


(define-resource agenda ()
  :class (s-prefix "vo-besluit:Agenda")
  :properties `((:name :string ,(s-prefix "ext:naam"))
                (:date-sent :date ,(s-prefix "prov-o:uitgestuurdOpDatum"))
                (:final :boolean ,(s-prefix "prov-o:finaleVersie")))
  :has-one `((session :via ,(s-prefix "ext:agenda")
                      :inverse t
                      :as "session"))
  :has-many `((agendaitem :via ,(s-prefix "ext:agendapunt")
                          :as "agendaitems"))
  :has-many `((comment :via ,(s-prefix "ext:opmerking")
                       :as "comments"))
  :resource-base (s-url "http://localhost/vo/agendas/")
  :on-path "agendas")


  (define-resource agendaitem ()
  :class (s-prefix "vo-besluit:AgendaPunt")
  :properties `((:priority :string ,(s-prefix "ext:prioriteit"))
                (:order-added :number ,(s-prefix "ext:volgordeVanToevoeging"))
                (:extended :boolean ,(s-prefix "ext:uitgesteld"))
                (:date-added :date ,(s-prefix "ext:datumVanToevoeging")))
  :has-one `((agenda :via ,(s-prefix "ext:agendapunt")
                     :inverse t
                     :as "agenda"))
  :has-many `((comment :via ,(s-prefix "ext:opmerking")
                      :as "comments"))
  :resource-base (s-url "http://localhost/vo/agendapunten/")
  :on-path "agendaitems")


  (define-resource comment ()
  :class (s-prefix "vo-besluit:Opmerking")
  :properties `((:text :string ,(s-prefix "ext:text"))
                (:created-at :date ,(s-prefix "ext:aangemaaktOp")))
  :has-one `((agenda :via ,(s-prefix "ext:opmerking")
                     :inverse t
                     :as "agenda"))
  :has-one `((agendaitem :via ,(s-prefix "ext:opmerking")
                     :inverse t
                     :as "agendaitem"))
  :resource-base (s-url "http://localhost/vo/opmerkingen/")
  :on-path "comments")



