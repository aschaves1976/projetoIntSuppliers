SELECT
         cfea.document_number
       , DECODE( cfbv.icms_contributor_flag, 'Y','S', 'N' )                                        icms_contributor_flag
       , DECODE( cfbv.highlight_ipi_flag, 'Y','S', 'N' )                                           ipi_contributor_flag -- novo
       , DECODE( cfbv.icms_contributor_flag, 'Y','S', 'N' )                                        pis_contributor_flag
       , cfea.ie                                                                                   inscricao_estadual
       , cfea.entity_id
       , ct.ibge_code
       , DECODE( pvsa.global_attribute9, '1', 'CPF', '2', 'CNPJ', '3' )                            classif
       , DECODE( pvsa.global_attribute9, '1', '1 - CLIENTE CONSUMIDOR'
                , '2', '2 - FORNECEDORES COMERCIALIZAVEIS', '3 - OUTROS'  )                        classif_desc
       , DECODE( pvsa.creation_date, pvsa.last_update_date, 'ORIGINAL', 'ADD' )                    tipo_acao
       , DECODE( pvsa.country, 'BR', 'S', 'N' )                                                    nacional
       , pv.vendor_name_alt
       , pv.vendor_name
       , pv.vendor_id -- novo
       , pv.last_update_date                                                                       data_alteracao_header -- novo
       , pv.enabled_flag                                                                           fornecedor_ativo-- novo
       , pvsa.vendor_site_id --novo
       , pvsa.last_update_date                                                                     data_alteracao_site -- novo
       , pvsa.inactive_date                                                                        data_inativacao_site --novo
       , pvsa.attribute1                                                                           cnae --novo
       , pvsa.attribute2                                                                           faixa_fat_anual --novo
       , pvsa.attribute3                                                                           natureza_juridica --novo
       , pvsa.attribute4                                                                           produtor_rural --novo
       , pvsa.attribute5                                                                           regime_trib_diferenciado --novo
       , pvsa.attribute6                                                                           simples_nacional --novo
       , pvsa.attribute7                                                                           vl_aliquota_icms --novo
       , pvsa.attribute8                                                                           fabricante_divisao
       , pvsa.global_attribute14                                                                   inscricao_municipal
       , pvsa.country
       , pvsa.state
       , pvsa.city
       , pvsa.zip
       , pvsa.address_line1
       , pvsa.address_line2
       , pvsa.address_line3
       , pvsa.address_line4
       , pvsa.email_address
       , pvsa.creation_date
       , NVL( pvsa.purchasing_site_flag,'N' )                                                      purchasing_site_flag
       , NVL( pvsa.pay_site_flag,'N' )                                                             pay_site_flag
       , CASE pvsa.global_attribute9
            WHEN '1' THEN -- CPF
              regexp_replace(LPAD(cfea.document_number,11,'0'),'([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})','\1.\2.\3-\4')
            WHEN '2' THEN -- CNPJ
              regexp_replace(cfea.document_number,'([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})','\1.\2.\3/\4-\5')
            ELSE cfea.document_number
          END cnpj_cpf
       , email.email_address
       , phone.phone_area_code
       , phone.phone_number
       , phone.phone_extension
  FROM
         apps.cll_f189_fiscal_entities_all cfea
       , apps.cll_f189_business_vendors cfbv
       , apps.cll_F189_cities ct
       , apps.po_vendor_sites_all pvsa
       , apps.po_vendors pv
       , (
           SELECT 
                    hcp.email_address
                  , hcp.phone_area_code
                  , hcp.phone_number
                  , hcp.phone_extension
                  , hr.object_id
                  --, hcp.*
             FROM
                    hz_relationships hr
                  , hz_contact_points hcp
           WHERE 1=1
             AND hr.party_id = hcp.owner_table_id--'1892438'
             AND hcp.contact_point_type = 'EMAIL'
           
         ) email
       , (
           SELECT 
                    hcp.phone_area_code
                  , hcp.phone_number
                  , hcp.phone_extension
                  , hr.object_id
                  --, hcp.*
             FROM
                    hz_relationships hr
                  , hz_contact_points hcp
           WHERE 1=1
             AND hr.party_id = hcp.owner_table_id--'1892438'
             AND hcp.contact_point_type = 'PHONE'
           
         ) phone
WHERE 1=1
  AND phone.object_id (+)            = pv.party_id
  AND email.object_id (+)            = pv.party_id
  AND NVL( pvsa.attribute15,'N' ) <> 'Y'
  AND cfea.business_vendor_id = cfbv.business_id( + )
  AND cfea.city_id = ct.city_id
  AND pvsa.vendor_id = pv.vendor_id
  AND cfea.vendor_site_id = pvsa.vendor_site_id
  AND regexp_replace( cfea.document_number,'( [0-9]{2} )( [0-9]{3} )( [0-9]{3} )( [0-9]{4} )( [0-9]{2} )','\1.\2.\3/\4-\5' ) = '31432792000105' --!= '00.000.000/0000-00'
;