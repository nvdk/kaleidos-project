(define-resource agenda ()
  ;; LEGACY: van elke agenda maar 1 versie, name is altijd A
  :class (s-prefix "besluitvorming:Agenda")
                
  :properties `(;; LEGACY: left blank
                (:issued :datetime ,(s-prefix "dct:issued"))
                ;; LEGACY: true
                (:is-final :boolean ,(s-prefix "besluitvorming:finaleVersie"))
                ;; LEGACY: set to A
                (:name    :string  ,(s-prefix "ext:agendaNaam"))
                ;; LEGACY: left blank
                (:created :date    ,(s-prefix "ext:aangemaaktOp"))
                ;; LEGACY: true
                (:is-accepted :boolean ,(s-prefix "ext:accepted")))
  :has-one `(
             ;; LEGACY: created based on agenda
             (meeting :via ,(s-prefix "besluit:isAangemaaktVoor")
                      :as "created-for")
             ;; LEGACY: won't exist
             (agenda :via ,(s-prefix "besluit:heeftAgenda")
                    :inverse t
                    :as "previous-version"))
  :has-many `((agendaitem :via ,(s-prefix "dct:hasPart")
                          :as "agendaitems")
              (announcement :via ,(s-prefix "ext:mededeling")
                           :as "announcements"))
  :resource-base (s-url "http://data.lblod.info/id/agendas/")
  :features '(include-uri)
  :on-path "agendas")

(define-resource agendaitem ()
  :class (s-prefix "besluit:Agendapunt")
  ;; LEGACY: incoming change: will get most properties of subcase
  :properties `(;; LEGACY: can be blank
                (:created     :datetime ,(s-prefix "besluitvorming:aanmaakdatum")) ;; NOTE: What is the URI of property 'aanmaakdatum'? Made up besluitvorming:aanmaakdatum
                ;; LEGACY: can be blank
                (:retracted   :boolean  ,(s-prefix "besluitvorming:ingetrokken")) ;; NOTE: What is the URI of property 'ingetrokken'? Made up besluitvorming:ingetrokken
                ;; LEGACY: set to agendapuntnummer
                (:priority    :number   ,(s-prefix "ext:prioriteit"))
                ;; LEGACY: don't know, leave blank
                (:for-press   :boolean  ,(s-prefix "ext:forPress"))
                ;; LEGACY: leave blank
                (:record      :string   ,(s-prefix "besluitvorming:notulen")) ;; NOTE: What is the URI of property 'notulen'? Made up besluitvorming:notulen
                ;; LEGACY: leave blank
                (:title-press :string   ,(s-prefix "besluitvorming:titelPersagenda"))
                ;; LEGACY: leave blank
                (:text-press  :string   ,(s-prefix "besluitvorming:tekstPersagenda"))) ;; NOTE: What is the URI of property 'titelPersagenda'? Made up besluitvorming:titelPersagenda
  :has-one `(;; LEGACY: best effort
             (postponed       :via      ,(s-prefix "ext:heeftVerdaagd") ;; instead of besluitvorming:verdaagd (mu-cl-resources relation type checking workaround)
                              :as "postponed-to")
             ;; LEGACY: ignore TODO: remove
             (agendaitem      :via      ,(s-prefix "besluit:aangebrachtNa")
                              :as "previousAgendaItem")
             (subcase         :via      ,(s-prefix "besluitvorming:isGeagendeerdVia")
                              :inverse t
                              :as "subcase")
             ;; LEGACY: dit is de beslissingsfiche
             (decision        :via      ,(s-prefix "ext:agendapuntHeeftBesluit") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                              :as "decision")
             (agenda          :via      ,(s-prefix "dct:hasPart")
                              :inverse t
                              :as "agenda")
             (newsletter-info :via      ,(s-prefix "prov:generated") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                              :inverse t
                              :as "newsletter-info")
             ;; LEGACY: leave blank
              (meeting-record :via      ,(s-prefix "ext:notulenVanAgendaPunt")
                              :as "meeting-record"))
  :has-many `(;; LEGACY: leave blank TODO: remove, specified in meeting-record
              (mandatee       :via     ,(s-prefix "besluit:heeftAanwezige")
                              :inverse t
                              :as "attendees")
              ;; LEGACY: leave blank
              (remark         :via      ,(s-prefix "besluitvorming:opmerking") ;; NOTE: opmerkingEN would be more suitable?
                              :as "remarks"))
  :resource-base (s-url "http://data.lblod.info/id/agendapunten/")
  :features '(include-uri)
  :on-path "agendaitems")

  ;; LEGACY: leave blank
  (define-resource approval ()
  :class (s-prefix "ext:Goedkeuring")
  :properties `((:approved  :string ,(s-prefix "ext:goedgekeurd"))
                (:created   :date ,(s-prefix "ext:aangemaakt"))
                (:modified  :date ,(s-prefix "ext:aangepast")))
  :has-one `((subcase       :via ,(s-prefix "ext:procedurestapGoedkeuring")
                            :inverse t
                            :as "subcase")
             (mandatee      :via ,(s-prefix "ext:goedkeuringen")
                            :inverse t
                            :as "mandatee"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Goedkeuringen/")
  :on-path "approvals")

  ;; LEGACY: best effort split between complex and simple announcement
  (define-resource announcement ()
  :class (s-prefix "vobesluit:Mededeling")
  :properties `((:title :string ,(s-prefix "ext:title"))
                ;; LEGACY: leave blank
                (:text :string ,(s-prefix "ext:text"))
                ;; LEGACY: leave blank
                (:created :date ,(s-prefix "ext:created"))
                ;; LEGACY: leave blank
                (:modified :date ,(s-prefix "ext:modified")))
  :has-one `((agenda :via ,(s-prefix "ext:mededeling")
                     :inverse t
                     :as "agenda"))
  :has-many `((document-version :via ,(s-prefix "ext:mededelingBevatDocumentversie")
                                 :as "document-versions"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Mededeling/")
  :on-path "announcements")

;; LEGACY: best effort
(define-resource postponed ()
  :class (s-prefix "besluitvorming:Verdaagd")
  :properties `((:postponed :boolean ,(s-prefix "besluitvorming:verdaagd")))
  :has-one `(;; LEGACY: leave blank
             (meeting :via ,(s-prefix "besluitvorming:nieuweDatum") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                      :inverse t
                      :as "meeting")
             (agendaitem :via ,(s-prefix "ext:heeftVerdaagd") ;; instead of besluitvorming:verdaagd (mu-cl-resources relation type checking workaround)
                         :inverse t
                         :as "agendaitem"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Verdaagd/")
  :features '(include-uri)
  :on-path "postponeds")

(define-resource decision ()
  :class (s-prefix "besluit:Besluit") ;; NOTE: Took over all properties from document instead of subclassing (mu-cl-resources workaround)
  :properties `(;; LEGACY: can try to use all other lines except for the first line of title as description
                (:description   :string     ,(s-prefix "eli:description"))
                ;; LEGACY: can try to use first line of title as short title
                (:short-title   :string     ,(s-prefix "eli:title_short"))
                ;; LEGACY: leave blank
                (:approved      :boolean    ,(s-prefix "besluitvorming:goedgekeurd")) ;; NOTE: What is the URI of property 'goedgekeurd'? Made up besluitvorming:goedgekeurd
                ;; LEGACY: leave blank
                (:archived      :boolean    ,(s-prefix "besluitvorming:gearchiveerd")) ;; NOTE: Inherited from Document
                ;; LEGACY: leave blank
                (:title         :string     ,(s-prefix "dct:title")) ;; NOTE: Inherited from Document
                ;; LEGACY: leave blank
                (:number-vp     :string     ,(s-prefix "besluitvorming:stuknummerVP")) ;; NOTE: Inherited from Document ;; NOTE: What is the URI of property 'stuknummerVP'? Made up besluitvorming:stuknummerVP
                ;; LEGACY: possibly rewritten to all follow same format
                (:number-vr     :string     ,(s-prefix "besluitvorming:stuknummerVR"))) ;; NOTE: Inherited from Document
  :has-many `(;; LEGACY: same as for agendaitem
              (mandatee         :via        ,(s-prefix "besluitvorming:neemtBesluit") ;; NOTE: What is the URI of property 'neemt' (Agent neemt besluit)? Guessed besluitvorming:neemtBesluit 
                                :as "mandatees")
              ;; LEGACY: leave blank
              (remark           :via        ,(s-prefix "besluitvorming:opmerking") ;; NOTE: Inherited from Document
                                :as "remarks")
              ; (documentversie :via ,(s-prefix "ext:documenttype")  ;; NOTE: Inherited from Document ;; NOTE: What is the URI of property 'heeftVersie'? Made up besluitvorming:heeftVersie
              ;           :as "heeft-versie")
              )
  :has-one `(;; LEGACY: same as subcase of agendaitem
             (subcase           :via        ,(s-prefix "ext:besluitHeeftProcedurestap") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                                :inverse t
                                :as "subcase")
             ;; LEGACY: got it
             (agendaitem        :via        ,(s-prefix "ext:agendapuntHeeftBesluit") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                                :inverse t
                                :as "agendaitem")
             ;; LEGACY: only have date
             (publication       :via        ,(s-prefix "besluitvorming:isGerealiseerdDoor")
                                :as "publication")
            ;;  (newsletter-info :via ,(s-prefix "prov:generated") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
             ;;                   :as "newsletter-info")
             ;; LEGACY: best effort
             (document-type     :via        ,(s-prefix "ext:documentType") ;; NOTE: Inherited from Document
                                :as "type")
             ;; LEGACY: leave blank, will be on subcase
             (confidentiality   :via        ,(s-prefix "besluitvorming:vertrouwelijkheid") ;; NOTE: Inherited from Document
                                :as "confidentiality"))
  :resource-base (s-url "http://data.lblod.info/id/besluiten/")
  :features '(include-uri)
  :on-path "decisions")

;; LEGACY: leave blank
(define-resource government-unit ()
  :class (s-prefix "besluit:Bestuurseenheid")
  :properties `((:name :string ,(s-prefix "skos:prefLabel")))
  :has-one `((jurisdiction-area :via ,(s-prefix "besluit:werkingsgebied")
                                   :as "area-of-jurisdiction")
             (government-unit-classification-code :via ,(s-prefix "besluit:classificatie")
                                                  :as "classification")
             (site :via ,(s-prefix "org:hasPrimarySite")
                   :as "primary-site"))
  :has-many `((contact-point :via ,(s-prefix "schema:contactPoint")
                            :as "contactinfo")
              (post :via ,(s-prefix "org:hasPost")
                    :as "posts")
              (government-body :via ,(s-prefix "besluit:bestuurt")
                               :inverse t
                               :as "government-bodies"))
  :resource-base (s-url "http://data.lblod.info/id/bestuurseenheden/")
  :features '(include-uri)
  :on-path "government-units")

;; Unmodified from lblod/loket
;; LEGACY: leave blank
(define-resource jurisdiction-area ()
  :class (s-prefix "prov:Location")
  :properties `((:name :string ,(s-prefix "rdfs:label"))
                (:level :string, (s-prefix "ext:werkingsgebiedNiveau")))
  :has-many `((government-unit :via ,(s-prefix "besluit:werkingsgebied")
                               :inverse t
                               :as "government-units"))
  :resource-base (s-url "http://data.lblod.info/id/werkingsgebieden/")
  :features '(include-uri)
  :on-path "jurisdiction-areas")

;; Unmodified from lblod/loket
;; LEGACY: leave blank
(define-resource government-unit-classification-code ()
  :class (s-prefix "ext:BestuurseenheidClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuurseenheidClassificatieCode/")
  :features '(include-uri)
  :on-path "government-unit-classification-codes")

;; LEGACY: add this
(define-resource government-body ()
  :class (s-prefix "besluit:Bestuursorgaan")
  :properties `((:name :string ,(s-prefix "skos:prefLabel"))
                (:binding-end :date ,(s-prefix "mandaat:bindingEinde"))
                (:binding-start :date ,(s-prefix "mandaat:bindingStart")))
  :has-one `(;; LEGACY: leave blank
             (government-unit :via ,(s-prefix "besluit:bestuurt")
                              :as "government-unit")
             ;; LEGACY: leave blank
             (government-body-classification-code :via ,(s-prefix "besluit:classificatie")
                                                  :as "classification")
             ;; LEGACY: simply make one instance, we don't bleeding care
             (government-body :via ,(s-prefix "mandaat:isTijdspecialisatieVan")
                             :as "is-tijdsspecialisatie-van"))
  :has-many `((mandate :via ,(s-prefix "org:hasPost")
                       :as "bevat"))
  :resource-base (s-url "http://data.lblod.info/id/bestuursorganen/")
  :features '(include-uri)
  :on-path "government-body")

;; Unmodified from lblod/loket
;; LEGACY: leave blank
(define-resource government-body-classification-code ()
  :class (s-prefix "ext:BestuursorgaanClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuursorgaanClassificatieCode/")
  :features '(include-uri)
  :on-path "government-body-classification-codes")

;; LEGACY: create one per agenda
(define-resource meeting ()
  :class (s-prefix "besluit:Zitting")
  :properties `(;; LEGACY: best effort 
                (:planned-start         :datetime ,(s-prefix "besluit:geplandeStart"))
                ;; LEGACY: same as planned-start
                (:started-on            :datetime ,(s-prefix "prov:startedAtTime")) ;; NOTE: Kept ':geplande-start' from besluit instead of ':start' from besluitvorming
                ;; LEGACY: same as effort
                (:ended-on              :datetime ,(s-prefix "prov:endedAtTime")) ;; NOTE: Kept ':geeindigd-op-tijdstip' from besluit instead of ':eind' from besluitvorming
                (:number                :number   ,(s-prefix "adms:identifier"))
                ;; LEGACY: leave blank (we don't have this either)
                (:location              :url      ,(s-prefix "prov:atLocation"))) ;; NOTE: besluitvorming mentions (unspecified) type 'Locatie' don't use this
  :has-many `((agenda                   :via      ,(s-prefix "besluit:isAangemaaktVoor")
                                        :inverse t
                                        :as "agendas")
              ;; LEGACY: hold for now, get back to karel after 18th of april
              (document-vo-identifier   :via      ,(s-prefix "ext:meeting")
                                        :as "identifiers"
                                        :inverse t)
              ;; LEGACY: leave blank
              (postponed                :via      ,(s-prefix "besluitvorming:nieuweDatum")
                                        :as "postponeds")
              ;; LEGACY: one to one mapped to agendaitem
              (subcase                  :via      ,(s-prefix "besluitvorming:isAangevraagdVoor")
                                        :inverse t
                                        :as "requested-subcases"))
  :has-one `((agenda                    :via      ,(s-prefix "besluitvorming:behandelt");; NOTE: What is the URI of property 'behandelt'? Made up besluitvorming:behandelt
                                        :as "agenda")
             ;; LEGACY: this will be realized as a file in the subcase
             (meeting-record            :via      ,(s-prefix "ext:algemeneNotulen")
                                        :as "notes")
             
             (newsletter-info           :via      ,(s-prefix "ext:algemeneNieuwsbrief")
                                        :as "newsletter"))
  :resource-base (s-url "http://data.lblod.info/id/zittingen/")
  :features '(include-uri)
  :on-path "meetings")

;; LEGACY: leave blank
(define-resource meeting-record ()
  :class (s-prefix "ext:Notule")
  :properties `((:modified      :date     ,(s-prefix "ext:aangepast")) 
                (:created       :date     ,(s-prefix "ext:aangemaaktOp"))
                (:announcements :string   ,(s-prefix "ext:mededelingen"))
                (:others        :string   ,(s-prefix "ext:varia"))
                (:description   :string   ,(s-prefix "ext:description"))) 
  :has-one `((meeting           :via      ,(s-prefix "ext:algemeneNotulen")
                                :inverse t
                                :as "meeting")
             (agendaitem        :via      ,(s-prefix "ext:notulenVanAgendaPunt")
                                :inverse t 
                                :as "agendaitem"))
  :has-many `((mandatee        :via      ,(s-prefix "ext:aanwezigen")
                                :as "attendees"))
  :resource-base (s-url "http://data.lblod.info/id/notulen/")
  :features '(include-uri)
  :on-path "meeting-records")
