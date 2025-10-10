<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Copy all content by default -->
    <xsl:template match="/">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- ':' not allowed: match element <seg> and then copy @source value substituting ':' with '_' -->
    <xsl:template match="//seg">
        <xsl:copy>
            <xsl:for-each select="@*">
                <xsl:choose>
                    <xsl:when test="name() = 'source'">
                        <xsl:attribute name="source">
                            <xsl:value-of select="replace(., ':', '_')"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- copy without modifications other attributes -->
                        <xsl:copy/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <!--copy other descendents without modifications -->
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- for each //back/div/ref: create a <cit> element with //ref/cit content ad update @xml:id -->
    <xsl:template match="back/div/ref">
        <cit>
            <!-- give to <cit> the value of @xml:id in <ref>, substituting ":" with "_" -->
            <xsl:attribute name="xml:id">
                <xsl:value-of select="replace(@xml:id, ':', '_')"/>
            </xsl:attribute>
            <!--copy all content of //ref/cit -->
            <xsl:apply-templates select="cit/node()"/>
        </cit>
    </xsl:template>

    <!-- Copy other elements without modifications -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
