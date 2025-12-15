using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace vtys
{
    public partial class Islemler : Form
    {
        public Islemler()
        {
            InitializeComponent();
        }
        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost;port=5432;Database=FilmProduction;user ID=postgres;password=Katalahali");
        private void btnPuan_Click(object sender, EventArgs e)
        {
            if (!decimal.TryParse(txtPuan.Text, out decimal minScore))
            {
                MessageBox.Show("Lutfen minimum puan icin gecerli bir rakam girin.");
                return;
            }


            string sorgu = "SELECT * FROM get_films_by_min_score_simple(@MinScore)";

            try
            {

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);


                da.SelectCommand.Parameters.AddWithValue("@MinScore", minScore);

                DataSet ds = new DataSet();
                da.Fill(ds, "Filmler");

                if (ds.Tables.Count > 0)
                {
                    dataGridView1.DataSource = ds.Tables[0];
                }
                else
                {
                    dataGridView1.DataSource = null;
                    MessageBox.Show("Hicbir film bulunamadi.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Veri cekme sirasinda bir hata olustu:\n{ex.Message}");
            }
        }

        private void btnSeeReleases_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(txtId.Text, out int id))
            {
                MessageBox.Show("Lütfen film ID'si icin gecerli bir tam sayi girin.");
                return;
            }

            string sorgu = "SELECT * FROM get_film_releases_by_film(@id)";

            try
            {

                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);


                da.SelectCommand.Parameters.AddWithValue("@id", id);

                DataSet ds = new DataSet();
                da.Fill(ds, "Filmler");

                if (ds.Tables.Count > 0)
                {
                    dataGridView1.DataSource = ds.Tables[0];
                }
                else
                {
                    dataGridView1.DataSource = null;
                    MessageBox.Show("Hicbir film bulunamadi.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Veri cekme sirasinda bir hata olustu:\n{ex.Message}");
            }
        }
        private void DisplayJsonInDataGridView(string json)
        {
            try
            {
                var jObject = JObject.Parse(json);
                DataTable dt = new DataTable();
                dt.Columns.Add("Key");
                dt.Columns.Add("Value");

                foreach (var property in jObject.Properties())
                {
                    dt.Rows.Add(property.Name, property.Value.ToString());
                }

                dataGridView1.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"JSON-u DataGridView üçün formatlama zamanı xəta: {ex.Message}\nJSON: {json}");
            }
        }

        private void btnFullFilm_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(txtId.Text, out int filmId))
            {
                MessageBox.Show("Lütfen film ID'si icin gecerli bir tam sayi girin.");
                return;
            }

            string sorgu = "SELECT get_complete_film_info(@FilmID)";

            try
            {
                using (var cmd = new NpgsqlCommand(sorgu, baglanti))
                {
                    if (baglanti.State != ConnectionState.Open)
                        baglanti.Open();

                    cmd.Parameters.AddWithValue("@FilmID", filmId);

                    object result = cmd.ExecuteScalar();

                    if (result != null)
                    {
                        string jsonResult = result.ToString();
                        DisplayJsonInDataGridView(jsonResult);
                    }
                    else
                    {
                        dataGridView1.DataSource = null;
                        MessageBox.Show($"ID {filmId} olan film icin tam bilgi bulunamadi.");
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Veri cekme sirasinda bir hata olustu:\n{ex.Message}");
            }
            finally
            {
                if (baglanti.State == ConnectionState.Open)
                    baglanti.Close();
            }
        }



        private void Islemler_Load(object sender, EventArgs e)
        {

        }

        private void btnPersonId_Click(object sender, EventArgs e)
        {
            NpgsqlCommand cmd = null;

            if (!int.TryParse(txtPersonId.Text, out int personId))
            {
                MessageBox.Show("Lütfen gecerli bir kisi ID'si girin.", "Input Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            try
            {
                if (baglanti.State != ConnectionState.Open)
                    baglanti.Open();

                cmd = new NpgsqlCommand("get_person_full_info", baglanti);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("p_personid", personId);

                NpgsqlParameter outParam = new NpgsqlParameter("result", NpgsqlTypes.NpgsqlDbType.Json);
                outParam.Direction = ParameterDirection.Output;
                cmd.Parameters.Add(outParam);

                cmd.ExecuteNonQuery();

                if (outParam.Value != null && outParam.Value != DBNull.Value)
                {
                    string jsonResult = outParam.Value.ToString();

                    if (jsonResult.Length > 10)
                    {
                        DisplayJsonInDataGridView(jsonResult);
                    }
                    else
                    {
                        dataGridView1.DataSource = null;
                        MessageBox.Show($"ID {personId} icin detayli bilgi bulunamadi.", "Resultado Vazio", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                }
                else
                {
                    dataGridView1.DataSource = null;
                    MessageBox.Show($"ID {personId} icin detayli bilgi bulunamadi.", "Resultado Vazio", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (NpgsqlException ex)
            {
                MessageBox.Show("Veritabani Hatasi: " + ex.Message, "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Bir hata oluştu: " + ex.Message, "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (baglanti != null && baglanti.State == ConnectionState.Open)
                {
                    baglanti.Close();
                }
                if (cmd != null)
                {
                    cmd.Dispose();
                }
            }
        }
    }
}

    



    

