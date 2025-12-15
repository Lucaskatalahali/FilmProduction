using Npgsql;
using System.Data;
using System.Reflection;
using System;
using System.Windows.Forms; 

namespace vtys
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost;port=5432;Database=FilmProduction;user ID=postgres;password=Katalahali");

        private void btnEkle_Click(object sender, EventArgs e)
        {
            NpgsqlCommand komut1 = null;

            if (string.IsNullOrWhiteSpace(txtFilmAdi.Text) || cmbKategori.SelectedItem == null)
            {
                MessageBox.Show("Filmin basligi ve kategori zorunludur.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string secilenKategori = cmbKategori.SelectedItem.ToString();

            object durationValue = null;
            if (!string.IsNullOrWhiteSpace(txtDuration.Text))
            {
                if (int.TryParse(txtDuration.Text, out int dakikaCinsindenSure))
                {
                    durationValue = TimeSpan.FromMinutes(dakikaCinsindenSure);
                }
                else
                {
                    MessageBox.Show("Sure, bir tam sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            object imdbValue = null;
            if (!string.IsNullOrWhiteSpace(txtImdb.Text))
            {
                if (double.TryParse(txtImdb.Text, out double imdbScore))
                {
                    imdbValue = imdbScore;
                }
                else
                {
                    MessageBox.Show("IMDB gecerli bir sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            bool isAnimation = (secilenKategori == "Animation");
            bool isLiveAction = (secilenKategori == "Live Action");

            try
            {
                baglanti.Open();

                komut1 = new NpgsqlCommand("insert into \"Film\"(title,imdb,animation,\"liveAction\",duration)values (@p1,@p2,@p3,@p4,@p5)", baglanti);

                komut1.Parameters.AddWithValue("@p1", txtFilmAdi.Text);
                komut1.Parameters.AddWithValue("@p2", imdbValue ?? DBNull.Value);
                komut1.Parameters.AddWithValue("@p3", isAnimation);
                komut1.Parameters.AddWithValue("@p4", isLiveAction);
                komut1.Parameters.AddWithValue("@p5", durationValue ?? DBNull.Value);

                komut1.ExecuteNonQuery();

                btnListele_Click(sender, e);
                MessageBox.Show("Film ekleme islemi basarili!", "Bilgi", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (NpgsqlException ex)
            {
                MessageBox.Show("Database Validation Failed: " + ex.Message, "Database Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            catch (Exception ex)
            {
                MessageBox.Show("An unexpected error occurred: " + ex.Message, "Fatal Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
                if (komut1 != null)
                {
                    komut1.Dispose();
                }
            }
        }

        private void btnListele_Click(object sender, EventArgs e)
        {
            string sorgu = "select * from \"Film\"";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
        }

        private void btnSil_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtId.Text) || !int.TryParse(txtId.Text, out _))
            {
                MessageBox.Show("Lutfen silmek icin gecerli bir film ID'si girin", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                baglanti.Open();
                NpgsqlCommand komut2 = new NpgsqlCommand("Delete from \"Film\" where \"filmId\"=@p1", baglanti);
                komut2.Parameters.AddWithValue("@p1", int.Parse(txtId.Text));
                komut2.ExecuteNonQuery();
                btnListele_Click(sender, e);
                MessageBox.Show("Film silme islemi basarili!", "Bilgi", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Filmi silme basarisiz oldu: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
            }
        }


        private void btnGuncelle_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtId.Text) || !int.TryParse(txtId.Text, out _))
            {
                MessageBox.Show("Lutfen guncellemek icin gecerli bir film ID'si girin", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            object durationValue = null;
            if (!string.IsNullOrWhiteSpace(txtDuration.Text))
            {
                if (int.TryParse(txtDuration.Text, out int dakikaCinsindenSure))
                {
                    durationValue = TimeSpan.FromMinutes(dakikaCinsindenSure);
                }
                else
                {
                    MessageBox.Show("Sure, bir tam sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            object imdbValue = null;
            if (!string.IsNullOrWhiteSpace(txtImdb.Text))
            {
                if (double.TryParse(txtImdb.Text, out double imdbScore))
                {
                    imdbValue = imdbScore;
                }
                else
                {
                    MessageBox.Show("IMDB gecerli bir sayi olmalidir.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
            }

            NpgsqlCommand komut3 = null;

            try
            {
                bool isAnimation = false;
                bool isLiveAction = false;

                if (cmbKategori.SelectedItem != null)
                {
                    string secilenKategori = cmbKategori.SelectedItem.ToString();
                    isAnimation = (secilenKategori == "Animation");
                    isLiveAction = (secilenKategori == "Live Action");
                }

                baglanti.Open();
                komut3 = new NpgsqlCommand("update \"Film\" set title=@p1,imdb=@p2,animation=@p3,\"liveAction\"=@p4,duration=@p5 where \"filmId\"=@p6", baglanti);

                object titleValue = string.IsNullOrWhiteSpace(txtFilmAdi.Text) ? null : txtFilmAdi.Text;

                komut3.Parameters.AddWithValue("@p1", titleValue ?? DBNull.Value);
                komut3.Parameters.AddWithValue("@p2", imdbValue ?? DBNull.Value);
                komut3.Parameters.AddWithValue("@p3", isAnimation);
                komut3.Parameters.AddWithValue("@p4", isLiveAction);
                komut3.Parameters.AddWithValue("@p5", durationValue ?? DBNull.Value);
                komut3.Parameters.AddWithValue("@p6", int.Parse(txtId.Text));

                komut3.ExecuteNonQuery();
                MessageBox.Show("Guncelleme islemi basarili!", "Bilgi", MessageBoxButtons.OK, MessageBoxIcon.Stop);
            }
            catch (NpgsqlException ex)
            {
                MessageBox.Show("Database Validation Failed: " + ex.Message, "Database Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Filmi guncelleme basarisiz oldu.: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
                if (komut3 != null)
                {
                    komut3.Dispose();
                }
            }
        }
        private void btnAra_Click(object sender, EventArgs e)
        {

            if (string.IsNullOrWhiteSpace(txtAra.Text))
            {
                MessageBox.Show("Lütfen aramak istediğiniz filmin başlığını girin.", "Uyarı", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            try
            {
                //
                string sorgu = "SELECT * FROM \"Film\" WHERE title ILIKE @p1";

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);


                da.SelectCommand.Parameters.AddWithValue("@p1", "%" + txtAra.Text + "%");

                DataSet ds = new DataSet();
                da.Fill(ds);


                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Arama sırasında hata oluştu: " + ex.Message, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnIslem_Click(object sender, EventArgs e)
        {
            Islemler newIslemlerFormu = new Islemler();

            newIslemlerFormu.Show();
        }

        private void btnKisiListele_Click(object sender, EventArgs e)
        {
            string sorgu2 = "select * from \"person\".\"Person\"";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu2, baglanti);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}