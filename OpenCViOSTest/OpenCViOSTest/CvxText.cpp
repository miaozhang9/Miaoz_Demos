#include <wchar.h>
#include <assert.h>
#include <locale.h>
#include <ctype.h>

#include "CvxText.h"

CvxText::CvxText(const char *freeType)
{
	assert(freeType != NULL);

	// ´ò¿ª×Ö¿âÎÄ¼þ, ´´½¨Ò»¸ö×ÖÌå

	if(FT_Init_FreeType(&m_library)) throw;
	if(FT_New_Face(m_library, freeType, 0, &m_face)) throw;

	// ÉèÖÃ×ÖÌåÊä³ö²ÎÊý

	restoreFont();

	// ÉèÖÃCÓïÑÔµÄ×Ö·û¼¯»·¾³

	setlocale(LC_ALL, "");
}

// ÊÍ·ÅFreeType×ÊÔ´

CvxText::~CvxText()
{
	FT_Done_Face    (m_face);
	FT_Done_FreeType(m_library);
}

// ÉèÖÃ×ÖÌå²ÎÊý:
//
// font         - ×ÖÌåÀàÐÍ, Ä¿Ç°²»Ö§³Ö
// size         - ×ÖÌå´óÐ¡/¿Õ°×±ÈÀý/¼ä¸ô±ÈÀý/Ðý×ª½Ç¶È
// underline   - ÏÂ»­Ïß
// diaphaneity   - Í¸Ã÷¶È

void CvxText::getFont(int *type, CvScalar *size, bool *underline, float *diaphaneity)
{
	if(type) *type = m_fontType;
	if(size) *size = m_fontSize;
	if(underline) *underline = m_fontUnderline;
	if(diaphaneity) *diaphaneity = m_fontDiaphaneity;
}

void CvxText::setFont(int *type, CvScalar *size, bool *underline, float *diaphaneity)
{
	// ²ÎÊýºÏ·¨ÐÔ¼ì²é

	if(type)
	{
		if(type >= 0) m_fontType = *type;
	}
	if(size)
	{
		m_fontSize.val[0] = fabs(size->val[0]);
		m_fontSize.val[1] = fabs(size->val[1]);
		m_fontSize.val[2] = fabs(size->val[2]);
		m_fontSize.val[3] = fabs(size->val[3]);

		FT_Set_Pixel_Sizes(m_face, (int)m_fontSize.val[0], 0);
	}
	if(underline)
	{
		m_fontUnderline   = *underline;
	}
	if(diaphaneity)
	{
		m_fontDiaphaneity = *diaphaneity;
	}

}

// »Ö¸´Ô­Ê¼µÄ×ÖÌåÉèÖÃ

void CvxText::restoreFont()
{
	m_fontType = 0;            // ×ÖÌåÀàÐÍ(²»Ö§³Ö)

	m_fontSize.val[0] = 25;      // ×ÖÌå´óÐ¡
	m_fontSize.val[1] = 0.5;   // ¿Õ°××Ö·û´óÐ¡±ÈÀý
	m_fontSize.val[2] = 0.1;   // ¼ä¸ô´óÐ¡±ÈÀý
	m_fontSize.val[3] = 0;      // Ðý×ª½Ç¶È(²»Ö§³Ö)

	m_fontUnderline   = false;   // ÏÂ»­Ïß(²»Ö§³Ö)

	m_fontDiaphaneity = 1.0;   // É«²Ê±ÈÀý(¿É²úÉúÍ¸Ã÷Ð§¹û)

	// ÉèÖÃ×Ö·û´óÐ¡

	FT_Set_Pixel_Sizes(m_face, (int)m_fontSize.val[0], 0);
}

// Êä³öº¯Êý(ÑÕÉ«Ä¬ÈÏÎªºÚÉ«)

int CvxText::putText(IplImage *img, const char *text, CvPoint pos)
{
	return putText(img, text, pos, CV_RGB(255,255,255));
}
int CvxText::putText(IplImage *img, const wchar_t *text, CvPoint pos)
{
	return putText(img, text, pos, CV_RGB(255,255,255));
}

//

int CvxText::putText(IplImage *img, const char *text, CvPoint pos, CvScalar color)
{
	if(img == NULL) return -1;
	if(text == NULL) return -1;

	//
	int i;
	for(i = 0; text[i] != '\0'; ++i)
	{
		wchar_t wc = text[i];

		// ½âÎöË«×Ö½Ú·ûºÅ

		if(!isascii(wc)) mbtowc(&wc, &text[i++], 2);

		// Êä³öµ±Ç°µÄ×Ö·û

		putWChar(img, wc, pos, color);
	}
	return i;
}

int CvxText::putText(IplImage *img, const wchar_t *text, CvPoint pos, CvScalar color)
{
	if(img == NULL) return -1;
	if(text == NULL) return -1;

	//

	int i;
	for(i = 0; text[i] != '\0'; ++i)
	{
		// Êä³öµ±Ç°µÄ×Ö·û

		putWChar(img, text[i], pos, color);
	}
	return i;
}

// Êä³öµ±Ç°×Ö·û, ¸üÐÂm_posÎ»ÖÃ

void CvxText::putWChar(IplImage *img, wchar_t wc, CvPoint &pos, CvScalar color)
{
	// ¸ù¾ÝunicodeÉú³É×ÖÌåµÄ¶þÖµÎ»Í¼

	FT_UInt glyph_index = FT_Get_Char_Index(m_face, wc);
	FT_Load_Glyph(m_face, glyph_index, FT_LOAD_DEFAULT);
	FT_Render_Glyph(m_face->glyph, FT_RENDER_MODE_MONO);

	//

	FT_GlyphSlot slot = m_face->glyph;

	// ÐÐÁÐÊý

	int rows = slot->bitmap.rows;
	int cols = slot->bitmap.width;

	//
	for(int i = 0; i < rows; ++i)
	{
		for(int j = 0; j < cols; ++j)
		{
			int off  = ((img->origin==0)? i: (rows-1-i))
				* slot->bitmap.pitch + j/8;

			if(slot->bitmap.buffer[off] & (0xC0 >> (j%8)))
			{
				int r = (img->origin==0)? pos.y - (rows-1-i): pos.y + i;;
				int c = pos.x + j;

				if(r >= 0 && r < img->height
					&& c >= 0 && c < img->width)
				{
					CvScalar scalar = cvGet2D(img, r, c);

					// ½øÐÐÉ«²ÊÈÚºÏ

					float p = m_fontDiaphaneity;
					for(int k = 0; k < 4; ++k)
					{
						scalar.val[k] = scalar.val[k]*(1-p) + color.val[k]*p;
					}

					cvSet2D(img, r, c, scalar);
				}
			}
		} // end for
	} // end for

	// ÐÞ¸ÄÏÂÒ»¸ö×ÖµÄÊä³öÎ»ÖÃ

	double space = m_fontSize.val[0]*m_fontSize.val[1];
	double sep   = m_fontSize.val[0]*m_fontSize.val[2];

	pos.x += (int)((cols? cols: space) + sep);
}