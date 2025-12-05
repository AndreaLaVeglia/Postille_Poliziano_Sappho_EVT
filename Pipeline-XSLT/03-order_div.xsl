<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- XML output -->
  <xsl:output method="xml" indent="no" />

  <!-- Copy all elements by default -->
  <xsl:template match="@*|node()">
  <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
  </xsl:copy>
  </xsl:template>

  <!-- Order all <div> by @id value and divide by <lb/> element -->
  <xsl:template match="back">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
            <xsl:for-each select="div">
            <xsl:sort select="replace(@xml:id, '\d+', '')" order="ascending" data-type="text" />
            <xsl:sort select="number(replace(@xml:id, '\D+', ''))" order="ascending" data-type="number" />
                <xsl:apply-templates />
                <lb />
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>