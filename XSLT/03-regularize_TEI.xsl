<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!--Copy all content by default -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />

    </xsl:copy>

  </xsl:template>

  <xsl:template match="//sourceDesc">
    <xsl:copy>
      <!--Copy all sons elements -->
      <xsl:apply-templates select="@*|node()" />
      
      <!-- Index of persons-->
      <listPerson>
        <head>Indice dei nomi</head>
        <xsl:apply-templates select="//persName" mode="sourceDesc" />
      </listPerson>

      <!--Index of places -->
      <listPlace>
        <head>Indice dei luoghi</head>
       <!-- Use an existing transformation or custom logic to generate content -->
        <xsl:apply-templates select="//placeName" mode="sourceDesc" />        
      </listPlace>
      
      <!-- Index of quoted works (marked with <title/>) -->
      <listBibl>
        <head>Indice delle opere citate</head>
        <xsl:apply-templates select="//text//title" mode="sourceDesc" /> 
      </listBibl>   
     
    </xsl:copy>
  </xsl:template>

  <!-- Create a list of loci paralleli and put in  //text/back -->
  <xsl:template match="//text">
    <xsl:copy>
      <!-- Copy all existing elements -->
      <xsl:apply-templates select="@*|node()" />
      
      <!-- Add the <back/> -->
      <back>
      <head>Loci Paralleli</head>
        <!--Add the template fot <quote/> -->
        <xsl:apply-templates select="//quote" mode="back" />
      </back>
    </xsl:copy>
  </xsl:template>

  <!-- Group in a new <facsimile/> element all the *<surface/> elements -->
  <xsl:template match="/TEI/facsimile">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
   </xsl:copy>
  </xsl:template>

  <xsl:template match="*/facsimile/facsimile">
    <xsl:apply-templates select="node()" />
  </xsl:template>


  <!-- Returns all <zone> elements to one level -->
  <xsl:template match="surface">
    <xsl:variable name="facsimileId" select="substring-after(parent::facsimile/@xml:id, 'facs_')" />
    <xsl:copy>
      <!-- Add the @corresp attribute, used by EVT to relate <surface> and section of //text/body -->
      <xsl:attribute name="corresp">
        <xsl:text>#pag</xsl:text>
      <xsl:value-of select="$facsimileId" />
      </xsl:attribute>

      <!-- Select and copy all children of <surface> that are not of type <zone> -->
      <xsl:apply-templates select="* [not(self::zone)]" />
      <!-- Copy zone elements that have indexMark--> as an attribute.
      <xsl:apply-templates select="zone[@subtype='indexMark']" />
      <!-- Selects only the child nodes of <surface> that are nested inside <zone> -->
      <xsl:apply-templates select="zone/*" />
    </xsl:copy>
  </xsl:template>


  <!-- Add @facs to each <zone> element, to create a double relationship between image and text -->
  <xsl:template match="zone">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="facs">#<xsl:value-of select="@xml:id" /></xsl:attribute>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>

  <!-- Add @xml:id to each <lb> element, to create double relationship between image and text -->
  <xsl:template match="lb">
    <xsl:copy>
      <!-- Copy all attributes except facs -->
      <xsl:copy-of select="@*[name()]" />

      <!-- Add xml:id based on facs -->
      <xsl:attribute name="xml:id">
        <xsl:value-of select="translate(@facs, '#', '')" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- Change the value of @rendition from "TextRegion" to "HotSpot" to display in EVT the referral signs -->
  <xsl:template match="zone[@rendition='TextRegion']">
      <xsl:copy>
      <!-- Copy all attributes, overwriting @rendition -->.
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="rendition">HotSpot</xsl:attribute>
      <xsl:attribute name="facs">#<xsl:value-of select="@xml:id" /></xsl:attribute>
      <!-- Applies patterns only to child nodes -->
      <xsl:apply-templates select="node()" />
      </xsl:copy>
  </xsl:template>

  <!-- Update the value of ./graphic/@url -->
  <xsl:template match="graphic/@url">
    <xsl:attribute name="url">data/images/single/<xsl:value-of select="." /></xsl:attribute>
  </xsl:template>

  <!-- Replace the value of ./pb/@facs with ./graphic/@url, as requested by EVT -->
  <xsl:template match="pb">
    <xsl:copy>
      <xsl:attribute name="facs">data/images/single/<xsl:value-of select="//facsimile[@xml:id = substring-after(current()/@facs, '#')]/surface/graphic/@url" />
      </xsl:attribute>
      <!-- Replace the name of ./pb/@n with xml:id -->
      <xsl:attribute name="xml:id">pag<xsl:value-of select="@n" />
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- Transforms <orig> elements according to the TEI standard -->
  <xsl:template match="//orig">
    <choice><orig><xsl:apply-templates /></orig><reg><xsl:value-of select="@reg" /></reg></choice>
  </xsl:template>

  <!-- Transforms <sic> elements according to the TEI-->
  <xsl:template match="sic">
    <choice><sic><xsl:value-of select="." /></sic><corr><xsl:value-of select="@correction" /></corr></choice>
  </xsl:template>

  <!-- creation of <del> tag, i.e., adding semantic value to deletions, thus visible in EVT-->
  <xsl:template match="hi[@rend='strikethrough:true;']">
    <del>
      <xsl:apply-templates />
    </del>
  </xsl:template>


  <!-- In Transkribus, citations have been marked with "quote" property to which "ref" "bibl" and "cit" attributes are associated to identify sources. Now we will proceed to mark the citation in the text with <seg> (segmentation) and then connect this portion of the text with the citation in an appendix (<back>) of the LociParallels -->

  <!-- Insert the contents of <quote> into <seg> -->
  <xsl:template match="quote">
    <xsl:variable name="refVal">
      <xsl:choose>
        <xsl:when test="@ref != ''"><xsl:value-of select="replace(@ref, ':', '_')" /></xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Replace <quote> with <seg> and add the link to the appendix of LociParallels-->
      <seg source="{$refVal}">
        <ref>
          <xsl:attribute name="target">
              <xsl:value-of select="@ref" />
          </xsl:attribute>
          <xsl:apply-templates />
        </ref>
      </seg>

  </xsl:template>

  <!-- Generate Appendix of Parallel Loci -->
  <xsl:template match="//quote" mode="back">
    <xsl:variable name="refVal">
      <xsl:choose>
        <xsl:when test="@ref != ''"><xsl:value-of select="replace(@ref, ':', '_')" /></xsl:when>
      </xsl:choose>
    </xsl:variable>

    <cit xml:id="{$refVal}">
        <quote>
          <xsl:value-of select="@cit" /></quote>
        <bibl>
          <xsl:value-of select="@bibl" /></bibl>
    </cit>
  </xsl:template>

  <!-- Transforms the attribute @wikiData (from Transkribus output) to @ref. In this way the WikiData ID becomes a key to locate personal entities -->
  <xsl:template match="@wikiData">
    <xsl:attribute name="ref">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

  <!-- Proceed to create an index of characters, places mentioned and works cited -->

  <!--Create an index of names mentioned in <sourceDesc> -->
  <xsl:template match="placeName" mode="sourceDesc">
    <xsl:variable name="refVal">
      <!-- Check if @wikidata attribute is missing -->
    <xsl:choose>
        <xsl:when test="not(@wikidata) or @wikidata = ''">
          <!-- Generates an increasing number for @ref -->
        <xsl:value-of select="generate-id()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(@wikiData)" />
        <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <place xml:id="{$refVal}">
        <placeName xml:lang="lat">
        <ref target="{if (@wikiData) then concat('https://wikidata.org/wiki/', normalize-space(@wikiData)) else ''}">
        <xsl:value-of select="." />
        </ref>
        </placeName>
    </place>
  </xsl:template>

  <!--Create an index of the people mentioned in <sourceDesc>-->
  <xsl:template match="persName" mode="sourceDesc">
    <xsl:variable name="refVal">
      <!-- Check if @wikidata attribute is missing -->
    <xsl:choose>
        <xsl:when test="not(@wikidata) or @wikidata = ''">
          <!-- Generate an increasing number for @ref -->
        <xsl:value-of select="generate-id()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(@wikiData)" />
        <xsl:text></xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <person xml:id="{$refVal}">
        <persName xml:lang="lat">
        <ref target="{if (@wikiData) then concat('https://wikidata.org/wiki/', normalize-space(@wikiData)) else ''}">
          <xsl:value-of select="." />
        </ref>
        </persName>
    </person>
  </xsl:template>

  <!--options mentioned (even if not yet managed in EVT)-->
  <xsl:template match="//text//title">
    <ref target="{if (@wikiData) then concat('https://wikidata.org/wiki/', normalize-space(@wikiData)) else ''}">
      <xsl:value-of select="." />
    </ref>
  </xsl:template>

  <!-- For each person, tagged with <persName> according to the TEI standard already in the output of Transkribus: 
   1) transform the initial to uppercase at the "interpretive" level 
   2) add a reference to the index of people mentioned using the key "wikiData" -->
  <xsl:template match="//persName">
    <persName>
    <xsl:choose>
        <!-- Check if it starts with a lowercase letter and has no children -->
      <xsl:when test="not(*) and starts-with(normalize-space(), translate(substring(normalize-space(), 1, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))">
        <choice>
          <!-- Variante originale con la minuscola -->
          <orig>
              <xsl:value-of select="." />
          </orig>
          <!-- Variante regolarizzata con la maiuscola -->
          <reg>
              <xsl:value-of select="concat(translate(substring(., 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring(., 2))" />
          </reg>
        </choice>
      </xsl:when>
        <!-- Altrimenti, copia l'elemento così com'è, con gli eventuali elementi "figli" -->
      <xsl:otherwise>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
    </persName>    
  </xsl:template>

</xsl:stylesheet>
