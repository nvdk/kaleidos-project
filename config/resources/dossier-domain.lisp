;; LEGACY: one to one mapped to subcase
(define-resource case ()
  :class (s-prefix "besluitvorming:Consultatievraag")
  :properties `((:created       :datetime ,(s-prefix "dct:created")) ;; NOTE: Type should be :date instead?
                (:short-title   :string   ,(s-prefix "dct:alternative"))
                (:number        :number   ,(s-prefix "adms:identifier")) ;; NOTE: Type should be :number instead?
                (:is-archived   :boolean   ,(s-prefix "ext:isGearchiveerd"))
                (:title         :string   ,(s-prefix "dct:title"))
                ;; LEGACY: vlaamse regering of overlegcommite, TODO karel this should be an uri
                (:policy-level  :string   ,(s-prefix "ext:beleidsNiveau")))
  :has-one `(;; LEGACY: best effort
             (case-type         :via      ,(s-prefix "dct:type")
                                :as "type"))
  :has-many `(;; LEGACY: leave blank
              (remark           :via      ,(s-prefix "besluitvorming:opmerking")
                                :as "opmerking") ;; NOTE: opmerkingEN would be more suitable?
              ;; LEGACY: leave blank
              (person           :via      ,(s-prefix "besluitvorming:heeftIndiener") ;; NOTE: used persoon instead of agent
                                :as "creators")
              ;; LEGACY: leave blank
              (person           :via      ,(s-prefix "besluitvorming:heeftContactpersoon") ;; NOTE: used persoon instead of agent
                                :as "contactPersons")
              ;; LEGACY: one to one mapped to case (and agendaitem)
              (subcase          :via      ,(s-prefix "dct:hasPart")
                                :as "subcases")
              ;; LEGACY: best effort
              (case             :via      ,(s-prefix "dct:relation")
                                :as "related"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Dossier/")
  :features '(include-uri)
  :on-path "cases")

;; LEGACY: ter mededeling / ter beslissing and since we only have agendaitems that have beslissingsfiches, we will always use 'ter beslissing'
(define-resource case-type ()
  :class (s-prefix "ext:DossierTypeCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((case :via ,(s-prefix "dct:type")
                       :inverse t
                       :as "cases"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/DossierTypeCode/")
  :features '(include-uri)
  :on-path "case-types")


;; LEGACY: one to one mapping to case and agendaitem
(define-resource subcase ()
  :class (s-prefix "dbpedia:UnitOfWork")
  :properties `(;; LEGACY: see beslissingsfiche (decision)
                (:short-title         :string ,(s-prefix "dct:alternative"))
                (:title               :string ,(s-prefix "dct:title"))
                ;; LEGACY: leave blank
                (:is-archived         :boolean   ,(s-prefix "ext:isProcedurestapGearchiveerd"))
                ;; LEGACY: leave blank
                (:formally-ok         :boolean  ,(s-prefix "besluitvorming:formeelOK")) ;; NOTE: What is the URI of property 'formeelOK'? Made up besluitvorming:formeelOK
                ;; LEGACY: leave blank
                (:created             :datetime ,(s-prefix "dct:created"))
                ;; LEGACY: best effort (differnce with announcement is tough)
                (:show-as-remark      :boolean ,(s-prefix "ext:wordtGetoondAlsMededeling"))) ;; NOTE: supplementary addition to model
  :has-one `((decision                :via ,(s-prefix "ext:besluitHeeftProcedurestap") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                                      :as "decision")
             (case                    :via ,(s-prefix "dct:hasPart")
                                      :inverse t
                                      :as "case")
             (meeting                 :via ,(s-prefix "besluitvorming:isAangevraagdVoor")
                                      :as "requested-for-meeting")
             (confidentiality         :via ,(s-prefix "besluitvorming:vertrouwelijkheid")
                                      :as "confidentiality"))
  :has-many `(;; LEGACY: leave blank
              (approval               :via      ,(s-prefix "ext:procedurestapGoedkeuring")
                                      :as "approvals")
              ;; LEGACY: leave blank, TODO karel: remove (separate story)
              (theme                  :via ,(s-prefix "dct:subject")
                                      :as "themes")
              ;; LEGACY: leave blank
              (person                 :via ,(s-prefix "dct:creator") ;; heeftCreator?  ;; NOTE: used persoon instead of agent
                                      :as "heeftCreator")
              (mandatee               :via ,(s-prefix "besluitvorming:heeftBevoegde") ;; NOTE: used mandataris instead of agent
                                      :as "mandatees")
              ;; LEGACY: leave blank
              (government-domain      :via ,(s-prefix "mandaat:beleidsdomein")  ;; TODO Currently no domains linked to subcases, only mandatees
                                      :as "government-domains")
              ;; LEGACY: best effort, same as for case
              (subcase                :via ,(s-prefix "dct:relation")
                                      :as "related-to")
              (document-version       :via ,(s-prefix "ext:bevatDocumentversie") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                                      :as "document-versions")
              ;; LEGACY: wait for karel, come back april 18th
              (document-vo-identifier :via ,(s-prefix "ext:procedurestap") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                                      :inverse t
                                      :as "document-identifiers")
              ;; LEGACY: leave blank
              (consultation-request   :via ,(s-prefix "ext:bevatConsultatievraag") ;; NOTE: instead of dct:hasPart (mu-cl-resources relation type checking workaround)
                                      :as "consultationRequests") ;; NOTE: consultatieVRAGEN would be more suitable?
              ;; LEGACY: use one to one mapped agendaitem
              (agendaitem             :via ,(s-prefix "besluitvorming:isGeagendeerdVia")
                                      :as "agendaitems")
              ;; LEGACY: don't have, tough luck buddy-boy
              (subcase-phase          :via ,(s-prefix "ext:subcaseProcedurestapFase")
                                      :as "phases")
              ;; LEGACY: leave blank
              (remark                 :via ,(s-prefix "besluitvorming:opmerking")
                                      :as "remarks"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Procedurestap/")
  :features '(include-uri)
  :on-path "subcases")

;; LEGACY: leave blank
(define-resource subcase-phase () ;; NOTE: Should be subclass of besluitvorming:Status (mu-cl-resources reasoner workaround)
  :class (s-prefix "ext:ProcedurestapFase") ;; NOTE: as well as skos:Concept
  :properties `((:remark :string ,(s-prefix "rdfs:comment"))
                (:label :string ,(s-prefix "skos:prefLabel"))
                (:date :datetime ,(s-prefix "besluitvorming:statusdatum")))
  :has-one `((subcase :via ,(s-prefix "ext:subcaseProcedurestapFase")
                          :inverse t
                          :as "subcase")
             (subcase-phase-code :via ,(s-prefix "ext:procedurestapFaseCode")
                       :as "code"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/ProcedurestapFase/")
  :features '(include-uri)
  :on-path "subcase-phases")

;; LEGACY: leave blank
(define-resource subcase-phase-code ()
  :class (s-prefix "ext:ProcedurestapFaseCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((subcase-phase :via ,(s-prefix "ext:procedurestapFaseCode")
                          :inverse t
                          :as "subcase-phases")
              (subcase-phase-code :via ,(s-prefix "skos:broader") ;; NOTE: tree structure for type-hierarchy (cfr codelist)
                                        :inverse t
                                        :as "subphase-codes"))
  :has-one `((subcase-phase-code :via ,(s-prefix "skos:broader")
                                      :as "superphase"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/ProcedurestapFaseCode/")
  :features '(include-uri)
  :on-path "subcase-phase-codes")

;; LEGACY: yes but derived
(define-resource confidentiality ()
  :class (s-prefix "ext:VertrouwelijkheidCode") ;; NOTE: as well as skos:Concept
  :properties `((:label       :string ,(s-prefix "skos:prefLabel"))
                (:scope-note  :string ,(s-prefix "skos:scopeNote")))
  :has-many `((subcase        :via ,(s-prefix "besluitvorming:vertrouwelijkheid")
                              :inverse t
                              :as "subcases")
              (document       :via ,(s-prefix "besluitvorming:vertrouwelijkheid")
                              :inverse t
                              :as "documents"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/VertrouwelijkheidCode/")
  :features '(include-uri)
  :on-path "confidentialities")

;; LEGACY: ignore, resources hack
(define-resource person-or-organization ()
  :class (s-prefix "ext:PersonOrOrganization") ;; NOTE: as resource hack for super typing, is person or organization
  :properties `((:type :string ,(s-prefix "rdfs:type")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/VertrouwelijkheidCode/")
  :features '(include-uri)
  :on-path "person-or-organization")

;; LEGACY: ignore
(define-resource consultation-request ()
  :class (s-prefix "besluitvorming:Consultatievraag")
  :properties `((:request :string ,(s-prefix "besluitvorming:aanvraag"))
                (:date :datetime ,(s-prefix "besluitvorming:aanvraagdatum"))) ;; NOTE: Type should be :date instead?
  :has-one `((subcase :via ,(s-prefix "ext:bevatConsultatievraag")
                            :inverse t
                            :as "subcase")
             (consultation-type :via ,(s-prefix "dct:type")
                               :as "type")
             (person-or-organization :via ,(s-prefix "besluitvorming:isGesteldAan") ;; NOTE: shoudl be Agent?
                                     :as "isGesteldAan")
             (person :via ,(s-prefix "besluitvorming:heeftContactpersoon") ;; NOTE: used persoon instead of agent
                     :as "contactPerson")
             (consultation-response :via ,(s-prefix "prov:generated")
                                    :as "response"))
  :has-many `((remark :via ,(s-prefix "besluitvorming:opmerking") ;; NOTE: opmerkingEN would be more suitable?
                      :as "remarks"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Consultatievraag/")
  :features '(include-uri)
  :on-path "consultation-requests")

;; LEGACY: ignore
(define-resource consultation-type ()
  :class (s-prefix "besluitvorming:Consultatietype")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((consultation-request :via ,(s-prefix "dct:type")
                          :inverse t
                          :as "requests"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/ConsultatieTypeCode/")
  :features '(include-uri)
  :on-path "consultation-types")

;; LEGACY: ignore
(define-resource consultation-response ()
  :class (s-prefix "besluitvorming:Consultatie-antwoord")
  :properties `((:date :datetime ,(s-prefix "besluitvorming:ontvangstdatum")) ;; NOTE: Type should be :date instead?
                (:text :string ,(s-prefix "besluitvorming:samenvatting")))
  :has-one `((consultation-response-code :via ,(s-prefix "besluitvorming:uitkomst")
                                         :as "result")
             (consultation-request :via ,(s-prefix "prov:generated")
                                   :inverse t
                                   :as "consultation-request"))
  :has-many `((remark :via ,(s-prefix "besluitvorming:opmerking")
                      :as "remarks")
              (document :via ,(s-prefix "dct:hasPart")
                        :as "documents"))
  :resource-base (s-url "http://data.vlaanderen.be/id/Consultatievraag/")
  :features '(include-uri)
  :on-path "consultation-responses")

;; LEGACY: leave blank
(define-resource consultation-response-code ()
  :class (s-prefix "ext:Consultatie-uitkomstCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel"))
                (:scope-note :string ,(s-prefix "skos:scopeNote")))
  :has-many `((consultation-response :via ,(s-prefix "besluitvorming:uitkomst")
                                     :inverse t
                                     :as "consultation-responses"))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/Consultatie-uitkomstCode/")
  :features '(include-uri)
  :on-path "consultation-response-codes")

