<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" version="1.0" encoding="utf-8"/>
  
  <xsl:template  match="Nodes/N">
    <bundle>
      <xsl:call-template name="node"/>
    </bundle>
  </xsl:template>
  
  <xsl:template name="node">
    <xsl:for-each select="N">
      <xsl:choose>
        <xsl:when test="@i">
          <image>
            <xsl:attribute name="src">
              <xsl:value-of select="@i"/>
            </xsl:attribute>
            <xsl:call-template name="node"/>
          </image>
        </xsl:when>
        <xsl:otherwise>
          <text>
            <xsl:attribute name="value">
              <xsl:value-of select="@t"/>
            </xsl:attribute>
            <xsl:call-template name="node"/>
          </text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
