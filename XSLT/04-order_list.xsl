<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="xml" indent="yes"/>

<!-- order <person> by @xml:id -->
  <xsl:key name="idKey" match="person" use="@xml:id"/>

  <xsl:template match="/">
    <root>
      <xsl:for-each select="//person">
        <xsl:sort select="@xml:id" data-type="text" order="ascending"/>
        <xsl:copy>
          <xsl:copy-of select="@*"/> <!-- Copy all attributes -->
          <xsl:copy-of select="*"/> <!-- Copy all descendent elements -->
        </xsl:copy>
      </xsl:for-each>
    </root>
  </xsl:template>

</xsl:stylesheet>
