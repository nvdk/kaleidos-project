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
  :has-many `((theme :via ,(s-prefix "dct:subject")
                     :as "themes")
              (capacity :via ,(s-prefix "vo-besluit:bevoegde")
                            :as "bevoegde")
              (subcase :via ,(s-prefix  "ext:deeldossier")
                     :as "subcases"))
  :has-one `((dossiertype :via ,(s-prefix "dct:type")
                          :as "dossierType")
             (capacity :via ,(s-prefix "vo-besluit:indiener")
                       :as "indiener")
             (capacity :via ,(s-prefix "vo-besluit:contact")
                       :as "contact")
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
                       :as "contact")
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
                (:number :number ,(s-prefix "vo-besluit:number")))
  :has-many `((agenda     :via ,(s-prefix "ext:agenda")
                          :as "agendas")
              (subcase    :via ,(s-prefix "ext:zitting")
                          :inverse t
                          :as "subcases")
              (agendaitem :via ,(s-prefix "vo-besluit:zitting")
                          :inverse t
                          :as "post-poned-agenda-items"))
  :resource-base (s-url "http://localhost/vo/zittingen/")
  :on-path "sessions")


(define-resource agenda ()
  :class (s-prefix "vo-besluit:Agenda")
  :properties `((:name :string ,(s-prefix "ext:naam"))
                (:date-sent :date ,(s-prefix "prov-o:uitgestuurdOpDatum"))
                (:final :boolean ,(s-prefix "prov-o:finaleVersie"))
                (:locked :boolean ,(s-prefix "ext:goedgekeurd")))
  :has-one `((session :via ,(s-prefix "ext:agenda")
                      :inverse t
                      :as "session"))
  :has-many `((agendaitem :via ,(s-prefix "ext:agendapunt")
                          :as "agendaitems")
              (comment :via ,(s-prefix "ext:opmerking")
                       :as "comments"))
  :resource-base (s-url "http://localhost/vo/agendas/")
  :on-path "agendas")


  (define-resource agendaitem ()
  :class (s-prefix "vo-besluit:AgendaPunt")
  :properties `((:priority :string ,(s-prefix "ext:prioriteit"))
                (:order-added :number ,(s-prefix "ext:volgordeVanToevoeging"))
                (:extended :boolean ,(s-prefix "ext:uitgesteld"))
                (:for-press :boolean ,(s-prefix "ext:forPress"))
                (:formally-ok :boolean ,(s-prefix "ext:formallyOk"))
                (:record :string ,(s-prefix "ext:record"))
                (:date-added :date ,(s-prefix "ext:datumVanToevoeging")))
  :has-one `((agenda    :via ,(s-prefix "ext:agendapunt")
                        :inverse t
                        :as "agenda")
             (decision  :via ,(s-prefix "ext:givesRiseToDecision")
                        :as "decision")
             (news-item :via ,(s-prefix "ext:givesRiseToNewsItem")
                        :as "news-item")
             (subcase   :via ,(s-prefix "vo-besluit:subcase")
                        :inverse t
                        :as "subcase")
             (session   :via ,(s-prefix "vo-besluit:zitting")
                        :as "post-poned-to-session"))
  :has-many `((comment  :via ,(s-prefix "ext:opmerking")
                        :as "comments"))
  :resource-base (s-url "http://localhost/vo/agendapunten/")
  :on-path "agendaitems")


  (define-resource comment ()
  :class (s-prefix "vo-besluit:Opmerking")
  :properties `((:text :string ,(s-prefix "ext:text"))
                (:created-at :date ,(s-prefix "ext:aangemaaktOp")))
  :has-one `((agenda :via ,(s-prefix "ext:opmerking")
                     :inverse t
                     :as "agenda")
            (agendaitem :via ,(s-prefix "ext:opmerking")
                     :inverse t
                     :as "agendaitem"))
  :resource-base (s-url "http://localhost/vo/opmerkingen/")
  :on-path "comments")

(define-resource subcase ()
  :class (s-prefix "ext:SubCase")
  :properties `((:short-title :string ,(s-prefix "vo-besluit:korteTitel"))
                (:number :string ,(s-prefix "vo-besluit:nummer"))
                (:created :date ,(s-prefix "dct:created"))
                (:remark :string ,(s-prefix "vo-besluit:opmerking"))
                (:title :string ,(s-prefix "dct:title")))
  :has-one `((case :via ,(s-prefix "ext:deeldossier")
                   :inverse t
                   :as "case")
             (session :via ,(s-prefix "ext:zitting")
                   :as "session")
             (agendaitem :via ,(s-prefix "vo-besluit:subcase")
                     :inverse t
                     :as "agendaitem"))
  :has-many `((document-version :via ,(s-prefix "ext:subcaseOfFileVersion")
                                :inverse t
                                :as "document-versions"))
  :resource-base (s-url "http://localhost/vo/deeldossiers/")
  :on-path "subcases")

(define-resource decision ()
  :class (s-prefix "vo-besluit:Besluit")
  :properties `((:text :string ,(s-prefix "ext:text"))
                (:approved :boolean ,(s-prefix "ext:approved")))
  :resource-base (s-url "http://localhost/vo/decisions/")
  :has-one `((agendaitem :via ,(s-prefix "ext:givesRiseToDecision")
                         :inverse  t
                         :as "agenda-item"))
  :on-path "decisions")

(define-resource news-item ()
  :class (s-prefix "vo-besluit:KortBestek")
  :properties `((:title :string ,(s-prefix "ext:title"))
                (:subtitle :string ,(s-prefix "ext:subtitle"))
                (:content :string ,(s-prefix "ext:content"))
                (:publication-date :date ,(s-prefix "ext:publicationDate")))
  :has-many `((theme :via ,(s-prefix "ext:theme")
                     :as "themes"))
  :has-one `((agendaitem :via ,(s-prefix "ext:givesRiseToNewsItem")
                         :inverse  t
                         :as "agenda-item"))
  :resource-base (s-url "http://localhost/vo/news-item/")
  :on-path "news-items")

(define-resource file ()
  :class (s-prefix "nfo:FileDataObject")
  :properties `((:filename :string ,(s-prefix "nfo:fileName"))
                (:format :string ,(s-prefix "dct:format"))
                (:size :number ,(s-prefix "nfo:fileSize"))
                (:extension :string ,(s-prefix "dbpedia:fileExtension"))
                (:created :datetime ,(s-prefix "nfo:fileCreated")))
  :has-one `((file :via ,(s-prefix "nie:dataSource")
                   :inverse t
                   :as "download")
            (document-version :via ,(s-prefix "ext:file")
                   :inverse t
                   :as "document-version"))
  :resource-base (s-url "http://localhost/vo/files/")
  :features `(include-uri)
  :on-path "files")

  (define-resource document-version ()
  :class (s-prefix "ext:documentVersie")
  :properties `((:version-number :string ,(s-prefix "ext:versieNummer"))
                (:created :datetime ,(s-prefix "ext:versieAangemaakt")))
  :has-one `((file   :via ,(s-prefix "ext:file")
                     :as "file")
            (subcase :via ,(s-prefix "ext:subcaseOfFileVersion")
                     :as "subcase"))
  :resource-base (s-url "http://localhost/vo/document-versions/")
  :features `(include-uri)
  :on-path "document-versions")