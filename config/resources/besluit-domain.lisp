(define-resource agenda ()
  :class (s-prefix "besluitvorming:Agenda")
  :properties `((:issued      :datetime   ,(s-prefix "dct:issued"))
                (:is-final    :boolean    ,(s-prefix "ext:finaleVersie"))
                (:name        :string     ,(s-prefix "ext:agendaNaam"))
                (:created     :date       ,(s-prefix "ext:aangemaaktOp"))
                (:modified    :datetime   ,(s-prefix "ext:aangepastOp"))
                (:is-accepted :boolean    ,(s-prefix "ext:accepted")))
  :has-one `((meeting         :via        ,(s-prefix "besluit:isAangemaaktVoor")
                              :as "created-for")
            (agenda           :via        ,(s-prefix "besluitvorming:heeftVorigeVersie")
                              :as "previous-version")
            (agenda           :via        ,(s-prefix "besluitvorming:heeftVorigeVersie")
                              :inverse t
                              :as "next-version")
            (file             :via        ,(s-prefix "ext:getekendeNotule")
                              :as "file"))
  :has-many `((agendaitem     :via        ,(s-prefix "dct:hasPart")
                              :as "agendaitems")
             (announcement    :via        ,(s-prefix "ext:mededeling")
                              :as "announcements"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/agendas/")
  :features '(include-uri)
  :on-path "agendas")

(define-resource agendaitem ()
  :class (s-prefix "besluit:Agendapunt")
  :properties `((:created             :datetime ,(s-prefix "besluitvorming:aanmaakdatum")) ;; NOTE: What is the URI of property 'aanmaakdatum'? Made up besluitvorming:aanmaakdatum
                (:retracted           :boolean  ,(s-prefix "besluitvorming:ingetrokken")) ;; NOTE: What is the URI of property 'ingetrokken'? Made up besluitvorming:ingetrokken
                (:priority            :number   ,(s-prefix "ext:prioriteit"))
                (:for-press           :boolean  ,(s-prefix "ext:forPress"))
                (:record              :string   ,(s-prefix "besluitvorming:notulen")) ;; NOTE: What is the URI of property 'notulen'? Made up besluitvorming:notulen
                (:title-press         :string   ,(s-prefix "besluitvorming:titelPersagenda"))
                (:text-press          :string   ,(s-prefix "besluitvorming:tekstPersagenda"))
                ;; Added properties from subcases
                (:short-title         :string   ,(s-prefix "dct:alternative"))
                (:title               :string   ,(s-prefix "dct:title"))
                (:modified            :datetime   ,(s-prefix "ext:modified"))
                (:formally-ok         :uri  ,(s-prefix "besluitvorming:formeelOK")) ;; NOTE: What is the URI of property 'formeelOK'? Made up besluitvorming:formeelOK
                (:show-as-remark      :boolean  ,(s-prefix "ext:wordtGetoondAlsMededeling"))) ;; NOTE: What is the URI of property 'titelPersagenda'? Made up besluitvorming:titelPersagenda
  :has-one `((postponed               :via      ,(s-prefix "ext:heeftVerdaagd") ;; instead of besluitvorming:verdaagd (mu-cl-resources relation type checking workaround)
                                      :as "postponed-to")
             (agendaitem              :via      ,(s-prefix "besluit:aangebrachtNa")
                                      :as "previousAgendaItem")
             (subcase                 :via      ,(s-prefix "besluitvorming:isGeagendeerdVia")
                                      :inverse t
                                      :as "subcase")
             (agenda                  :via      ,(s-prefix "dct:hasPart")
                                      :inverse t
                                      :as "agenda")
             (meeting-record          :via      ,(s-prefix "ext:notulenVanAgendaPunt")
                                      :as "meeting-record"))
  :has-many `((mandatee               :via     ,(s-prefix "besluit:heeftAanwezige")
                                      :inverse t
                                      :as "attendees")
              (remark                 :via      ,(s-prefix "besluitvorming:opmerking") ;; NOTE: opmerkingEN would be more suitable?
                                      :as "remarks")
            ;; Added has-many relations from subcases
              (approval               :via      ,(s-prefix "ext:agendapuntGoedkeuring")
                                      :as "approvals")
              (theme                  :via      ,(s-prefix "ext:agendapuntSubject")
                                      :as "themes")
              (mandatee               :via      ,(s-prefix "besluitvorming:heeftBevoegdeVoorAgendapunt") ;; NOTE: used mandataris instead of agent
                                      :as "mandatees")
              (document-version       :via      ,(s-prefix "ext:bevatAgendapuntDocumentversie") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                                      :as "document-versions")
              (subcase-phase          :via      ,(s-prefix "ext:subcaseAgendapuntFase")
                                      :as "phases"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/agendapunten/")
  :features `(no-pagination-defaults include-uri)
  :on-path "agendaitems")


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
                            :as "mandatee")
             (agendaitem    :via ,(s-prefix "ext:agendapuntGoedkeuring")
                            :inverse t
                            :as "agendaitem"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/goedkeuringen/")
  :on-path "approvals")


  (define-resource announcement ()
  :class (s-prefix "besluitvorming:Mededeling")
  :properties `((:title         :string ,(s-prefix "ext:title"))
                (:text          :string ,(s-prefix "ext:text"))
                (:created       :date ,(s-prefix "ext:created"))
                (:modified      :date ,(s-prefix "ext:modified")))
  :has-one `((agenda            :via ,(s-prefix "ext:mededeling")
                                :inverse t
                                :as "agenda"))
  :has-many `((document-version :via ,(s-prefix "ext:mededelingBevatDocumentversie")
                                :as "document-versions"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/mededelingen/")
  :on-path "announcements")


(define-resource postponed ()
  :class (s-prefix "besluitvorming:Verdaagd")
  :properties `((:postponed     :boolean ,(s-prefix "besluitvorming:verdaagd")))
  :has-one `((meeting           :via ,(s-prefix "besluitvorming:nieuweDatum") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                                :inverse t
                                :as "meeting")
             (agendaitem        :via ,(s-prefix "ext:heeftVerdaagd") ;; instead of besluitvorming:verdaagd (mu-cl-resources relation type checking workaround)
                                :inverse t
                                :as "agendaitem"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/verdaagden/")
  :features '(include-uri)
  :on-path "postponeds")

(define-resource decision ()
  :class (s-prefix "besluit:Besluit") ;; NOTE: Took over all properties from document instead of subclassing (mu-cl-resources workaround)
  :properties `((:description   :string     ,(s-prefix "eli:description"))
                (:short-title   :string     ,(s-prefix "eli:title_short"))
                (:approved      :boolean    ,(s-prefix "besluitvorming:goedgekeurd")) ;; NOTE: What is the URI of property 'goedgekeurd'? Made up besluitvorming:goedgekeurd
                (:archived      :boolean    ,(s-prefix "besluitvorming:gearchiveerd")) ;; NOTE: Inherited from Document
                (:title         :string     ,(s-prefix "dct:title")) ;; NOTE: Inherited from Document
                (:number-vp     :string     ,(s-prefix "besluitvorming:stuknummerVP")) ;; NOTE: Inherited from Document ;; NOTE: What is the URI of property 'stuknummerVP'? Made up besluitvorming:stuknummerVP
                (:number-vr     :string     ,(s-prefix "besluitvorming:stuknummerVR"))
                (:richtext      :string   ,(s-prefix "ext:htmlInhoud"))) ;; NOTE: Inherited from Document
  :has-many `((mandatee         :via        ,(s-prefix "besluitvorming:neemtBesluit") ;; NOTE: What is the URI of property 'neemt' (Agent neemt besluit)? Guessed besluitvorming:neemtBesluit
                                :as "mandatees")
              (remark           :via        ,(s-prefix "besluitvorming:opmerking") ;; NOTE: Inherited from Document
                                :as "remarks")
              ; (documentversie :via ,(s-prefix "ext:documenttype")  ;; NOTE: Inherited from Document ;; NOTE: What is the URI of property 'heeftVersie'? Made up besluitvorming:heeftVersie
              ;           :as "heeft-versie")
              (document-version :via ,(s-prefix "ext:documentenVoorBeslissing")
                                :as "document-versions"))
  :has-one `((subcase           :via        ,(s-prefix "ext:procedurestapHeeftBesluit") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                                :inverse t
                                :as "subcase")
             (agendaitem        :via        ,(s-prefix "ext:agendapuntHeeftBesluit") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
                                :inverse t
                                :as "agendaitem")
             (publication       :via        ,(s-prefix "besluitvorming:isGerealiseerdDoor")
                                :as "publication")
            ;;  (newsletter-info :via ,(s-prefix "prov:generated") ;; instead of prov:generated (mu-cl-resources relation type checking workaround)
            ;;                   :as "newsletter-info")
             (document-type     :via        ,(s-prefix "ext:documentType") ;; NOTE: Inherited from Document
                                :as "type")
             (document          :via      ,(s-prefix "ext:beslissingsfiche")
                                :as "signed-document"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/besluiten/")
  :features '(include-uri)
  :on-path "decisions")

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
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/bestuurseenheden/")
  :features '(include-uri)
  :on-path "government-units")

;; Unmodified from lblod/loket
(define-resource jurisdiction-area ()
  :class (s-prefix "prov:Location")
  :properties `((:name :string ,(s-prefix "rdfs:label"))
                (:level :string, (s-prefix "ext:werkingsgebiedNiveau")))
  :has-many `((government-unit :via ,(s-prefix "besluit:werkingsgebied")
                               :inverse t
                               :as "government-units"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/werkingsgebieden/")
  :features '(include-uri)
  :on-path "jurisdiction-areas")

;; Unmodified from lblod/loket
(define-resource government-unit-classification-code ()
  :class (s-prefix "ext:BestuurseenheidClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote"))
                (:alt-label :string ,(s-prefix "skos:altLabel")))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/bestuurseenheid-classificatie-codes/")
  :features '(include-uri)
  :on-path "government-unit-classification-codes")

(define-resource government-body ()
  :class (s-prefix "besluit:Bestuursorgaan")
  :properties `((:name :string ,(s-prefix "skos:prefLabel"))
                (:binding-end :date ,(s-prefix "mandaat:bindingEinde"))
                (:binding-start :date ,(s-prefix "mandaat:bindingStart"))
                (:deprecated    :bool   ,(s-prefix "owl:deprecated")))
  :has-one `((government-unit :via ,(s-prefix "besluit:bestuurt")
                              :as "government-unit")
             (government-body-classification-code :via ,(s-prefix "besluit:classificatie")
                                                  :as "classification")
             (government-body :via ,(s-prefix "mandaat:isTijdspecialisatieVan")
                             :as "is-tijdsspecialisatie-van"))
  :has-many `((government-body :via ,(s-prefix "mandaat:isTijdspecialisatieVan")
                                    :inverse t
                                    :as "has-terms")
              (mandate :via ,(s-prefix "org:hasPost")
                       :as "bevat"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/bestuursorganen/")
  :features '(include-uri)
  :on-path "government-bodies")

;; Unmodified from lblod/loket
(define-resource government-body-classification-code ()
  :class (s-prefix "ext:BestuursorgaanClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote"))
                (:alt-label :string ,(s-prefix "skos:altLabel")))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/concept/bestuursorgaan-classificatie-codes/")
  :features '(include-uri)
  :on-path "government-body-classification-codes")

(define-resource meeting ()
  :class (s-prefix "besluit:Zitting")
  :properties `((:planned-start         :datetime ,(s-prefix "besluit:geplandeStart"))
                (:started-on            :datetime ,(s-prefix "prov:startedAtTime")) ;; NOTE: Kept ':geplande-start' from besluit instead of ':start' from besluitvorming
                (:ended-on              :datetime ,(s-prefix "prov:endedAtTime")) ;; NOTE: Kept ':geeindigd-op-tijdstip' from besluit instead of ':eind' from besluitvorming
                (:number                :number   ,(s-prefix "adms:identifier"))
                (:is-final              :boolean  ,(s-prefix "ext:finaleZittingVersie"))
                (:kind                  :uri      ,(s-prefix "ext:aard"))
                (:extra-info            :string   ,(s-prefix "ext:extraInfo"))
                (:location              :url      ,(s-prefix "prov:atLocation"))) ;; NOTE: besluitvorming mentions (unspecified) type 'Locatie' don't use this
  :has-many `((agenda                   :via      ,(s-prefix "besluit:isAangemaaktVoor")
                                        :inverse t
                                        :as "agendas")
              (postponed                :via      ,(s-prefix "besluitvorming:nieuweDatum")
                                        :as "postponeds")
              (subcase                  :via      ,(s-prefix "besluitvorming:isAangevraagdVoor")
                                        :inverse t
                                        :as "requested-subcases")
              (case                     :via       ,(s-prefix "ext:heeftBijbehorendeDossiers")
                                        :as "related-cases"))
  :has-one `((agenda                    :via      ,(s-prefix "besluitvorming:behandelt");; NOTE: What is the URI of property 'behandelt'? Made up besluitvorming:behandelt
                                        :as "agenda")
             (meeting-record            :via      ,(s-prefix "ext:algemeneNotulen")
                                        :as "notes")
             (newsletter-info           :via      ,(s-prefix "ext:algemeneNieuwsbrief")
                                        :as "newsletter")
             (signature                 :via      ,(s-prefix "ext:heeftHandtekening")
                                        :as "signature")
             (mail-campaign             :via      ,(s-prefix "ext:heeftMailCampagnes")
                                        :as "mail-campaign"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/zittingen/")
  :features '(include-uri)
  :on-path "meetings")

(define-resource meeting-record ()
  :class (s-prefix "ext:Notule")
  :properties `((:modified      :date     ,(s-prefix "ext:aangepast"))
                (:created       :date     ,(s-prefix "ext:aangemaaktOp"))
                (:announcements :string   ,(s-prefix "ext:mededelingen"))
                (:others        :string   ,(s-prefix "ext:varia"))
                (:description   :string   ,(s-prefix "ext:description"))
                (:richtext      :string   ,(s-prefix "ext:htmlInhoud")))
  :has-one `((meeting           :via      ,(s-prefix "ext:algemeneNotulen")
                                :inverse t
                                :as "meeting")
             (agendaitem        :via      ,(s-prefix "ext:notulenVanAgendaPunt")
                                :inverse t
                                :as "agendaitem")
             (document          :via      ,(s-prefix "ext:getekendeNotulen")
                                :as "signed-document"))
  :has-many `((mandatee        :via      ,(s-prefix "ext:aanwezigen")
                                :as "attendees")
              (document-version :via      ,(s-prefix "ext:getekendeDocumentVersiesVoorNotulen")
                                :as "document-versions"))
  :resource-base (s-url "http://kanselarij.vo.data.gift/id/notulen/")
  :features '(include-uri)
  :on-path "meeting-records")
